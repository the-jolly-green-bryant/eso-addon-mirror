local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}
Nvk3UT.UI = Nvk3UT.UI or {}

local TrackerHost = {}
TrackerHost.__index = TrackerHost

TrackerHost.questSectionContainer = nil
TrackerHost.endeavorSectionContainer = nil
TrackerHost.achievementSectionContainer = nil
TrackerHost.goldenSectionContainer = nil
TrackerHost.sectionContainers = TrackerHost.sectionContainers or {}

local ROOT_CONTROL_NAME = addonName .. "_UI_Root"
local QUEST_CONTAINER_NAME = addonName .. "_QuestContainer"
local ENDEAVOR_CONTAINER_NAME = addonName .. "_EndeavorContainer"
local ACHIEVEMENT_CONTAINER_NAME = addonName .. "_AchievementContainer"
local GOLDEN_CONTAINER_NAME = addonName .. "_GoldenContainer"
local SECTION_TEMPLATE_NAME = "Nvk3UT_SectionContainerTemplate"
local SCROLL_CONTAINER_NAME = addonName .. "_ScrollContainer"
local SCROLL_BACKGROUND_NAME = SCROLL_CONTAINER_NAME .. "_Background"
local SCROLL_CONTENT_NAME = SCROLL_CONTAINER_NAME .. "_Content"
local SCROLLBAR_NAME = SCROLL_CONTAINER_NAME .. "_ScrollBar"
local RESIZE_GRIP_NAME = addonName .. "_ResizeGrip"
local RESIZE_EVENT_NAMESPACE = addonName .. "_ManualResize"
local RESIZE_BORDER_THICKNESS = 20 -- ~0.5 cm border area for manual resize grips
local HEADER_BAR_NAME = SCROLL_CONTENT_NAME .. "_HeaderBar"
local CONTENT_STACK_NAME = SCROLL_CONTENT_NAME .. "_ContentStack"
local FOOTER_BAR_NAME = SCROLL_CONTENT_NAME .. "_FooterBar"

local MIN_WIDTH = 260
local MIN_HEIGHT = 240
local RESIZE_HANDLE_SIZE = 12
local RESIZE_GRIP_SIZE = 26 -- larger corner grips for easier interactions
local SCROLLBAR_WIDTH = 18
local SCROLLBAR_SIDE_INSET_FIX = 20
local SCROLL_OVERSHOOT_PADDING = 0 -- no overshoot, scroll range == content height
local FRAGMENT_RETRY_DELAY_MS = 200
local MAX_BAR_HEIGHT = 250

local FRAGMENT_REASON_SUPPRESSED = "NVK3UT_SUPPRESSED"
local FRAGMENT_REASON_USER = "NVK3UT_USER"
local FRAGMENT_REASON_SCENE = "NVK3UT_SCENE"
local FRAGMENT_REASON_COMBAT = "NVK3UT_COMBAT"
local FRAGMENT_REASON_LAM = "NVK3UT_LAM"

local DEFAULT_APPEARANCE = {
    enabled = true,
    alpha = 0.6,
    edgeEnabled = true,
    edgeAlpha = 0.65,
    edgeThickness = 2,
    padding = 12,
    cornerRadius = 0,
    theme = "dark",
}

local DEFAULT_BACKDROP_TEXTURE = {
    texture = "EsoUI/Art/Tooltips/UI-Border.dds",
    tileSize = 64,
    edgeWidth = 16,
}

local DEFAULT_WINDOW = {
    left = 200,
    top = 200,
    width = 360,
    height = 640,
    locked = false,
    visible = true,
    clamp = true,
    onTop = false,
}

local DEFAULT_LAYOUT = {
    autoGrowV = false,
    autoGrowH = false,
    minWidth = MIN_WIDTH,
    minHeight = MIN_HEIGHT,
    maxWidth = 640,
    maxHeight = 900,
}

local DEFAULT_WINDOW_BARS = {
    headerHeightPx = 40,
    footerHeightPx = 100,
}

local DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR = { r = 1, g = 1, b = 0.6, a = 1 }

local DEFAULT_TRACKER_COLORS = {
    questTracker = {
        mouseoverHighlightColor = DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR,
        colors = {
            categoryTitle = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
            objectiveText = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
            entryTitle = { r = 1, g = 1, b = 0, a = 1 },
            activeTitle = { r = 1, g = 1, b = 1, a = 1 },
        },
    },
    achievementTracker = {
        mouseoverHighlightColor = DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR,
        colors = {
            categoryTitle = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
            objectiveText = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
            entryTitle = { r = 1, g = 1, b = 0, a = 1 },
            activeTitle = { r = 1, g = 1, b = 1, a = 1 },
        },
    },
    endeavorTracker = {
        mouseoverHighlightColor = DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR,
        colors = {
            categoryTitle = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
            objectiveText = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
            entryTitle = { r = 1, g = 1, b = 0, a = 1 },
            activeTitle = { r = 1, g = 1, b = 1, a = 1 },
            completed = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
        },
    },
    goldenTracker = {
        mouseoverHighlightColor = DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR,
        colors = {
            categoryTitleClosed = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
            categoryTitleOpen = { r = 1, g = 1, b = 0, a = 1 },
            entryTitle = { r = 1, g = 1, b = 0, a = 1 },
            objectiveText = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 },
            activeTitle = { r = 1, g = 1, b = 1, a = 1 },
            completed = { r = 0.6, g = 0.6, b = 0.6, a = 1 },
        },
    },
}

local DEFAULT_COLOR_FALLBACK = { r = 1, g = 1, b = 1, a = 1 }
local GOLDEN_TRACKER_TYPE = "goldenTracker"
local GOLDEN_COLOR_INIT_TAG = "GoldenColorInit"
local GOLDEN_COLOR_INIT_ROLES = {
    "categoryTitleClosed",
    "categoryTitleOpen",
    "entryTitle",
    "objectiveText",
    "activeTitle",
    "completed",
}
local CORNER_BUTTON_SIZE = 32
local COLLAPSED_MIN_WIDTH = 64
local COLLAPSED_MIN_HEIGHT = 48
local DEFAULT_CORNER_POSITION = "TOP_RIGHT"
local CORNER_TEXTURES = {
    normal = "EsoUI/Art/Buttons/tree_closed_up.dds",
    hover = "EsoUI/Art/Buttons/tree_closed_over.dds",
    pressed = "EsoUI/Art/Buttons/tree_closed_over.dds",
}
local CORNER_ROTATIONS = {
    TOP_RIGHT = math.rad(225),
    TOP_LEFT = math.rad(315),
    BOTTOM_RIGHT = math.rad(135),
    BOTTOM_LEFT = math.rad(45),
}

local CORNER_ANCHORS = {
    TOP_RIGHT = { point = TOPRIGHT, relative = TOPRIGHT, offsetX = -4, offsetY = 4 },
    TOP_LEFT = { point = TOPLEFT, relative = TOPLEFT, offsetX = 4, offsetY = 4 },
    BOTTOM_RIGHT = { point = BOTTOMRIGHT, relative = BOTTOMRIGHT, offsetX = -4, offsetY = -4 },
    BOTTOM_LEFT = { point = BOTTOMLEFT, relative = BOTTOMLEFT, offsetX = 4, offsetY = -4 },
}

local LEFT_MOUSE_BUTTON = _G.MOUSE_BUTTON_INDEX_LEFT or 1
local MOUSE_CURSOR_RESIZE_EW = _G.MOUSE_CURSOR_RESIZE_EW
local MOUSE_CURSOR_RESIZE_NS = _G.MOUSE_CURSOR_RESIZE_NS
local MOUSE_CURSOR_RESIZE_NESW = _G.MOUSE_CURSOR_RESIZE_NESW
local MOUSE_CURSOR_RESIZE_NWSE = _G.MOUSE_CURSOR_RESIZE_NWSE
local MOUSE_CURSOR_DO_NOT_CARE = _G.MOUSE_CURSOR_DO_NOT_CARE
local MOUSE_CURSOR_DEFAULT_CURSOR = _G.MOUSE_CURSOR_DEFAULT_CURSOR

local function Num0(v)
    if type(v) == "number" then
        return v
    end
    if type(v) == "function" then
        local ok, val = pcall(v)
        if ok and type(val) == "number" then
            return val
        end
        return 0
    end
    return 0
end

local function getEndeavorModule()
    local addon = rawget(_G, addonName)
    if type(addon) ~= "table" then
        addon = Nvk3UT
    end

    if type(addon) ~= "table" then
        return nil
    end

    local facade = rawget(addon, "Endeavor")
    if type(facade) == "table" then
        return facade
    end

    local tracker = rawget(addon, "EndeavorTracker")
    if type(tracker) == "table" then
        return tracker
    end

    return nil
end

local DEFAULT_SECTION_ORDER_KEYS = {
    "questSectionContainer",
    "endeavorSectionContainer",
    "achievementSectionContainer",
    "goldenSectionContainer",
}

local SECTION_KEY_TO_ID = {
    questSectionContainer = "quest",
    endeavorSectionContainer = "endeavor",
    achievementSectionContainer = "achievement",
    goldenSectionContainer = "golden",
}

local DEFAULT_HOST_SETTINGS = {
    HideInCombat = false,
    CornerButtonEnabled = true,
    CornerPosition = "TOP_RIGHT",
    contentAlign = "left",
    scrollbarSide = "right",
    sectionOrder = DEFAULT_SECTION_ORDER_KEYS,
}

local state = {
    initialized = false,
    root = nil,
    fragment = nil,
    fragmentScenes = nil,
    fragmentRetryScheduled = false,
    scrollContainer = nil,
    scrollContent = nil,
    scrollbar = nil,
    clientArea = nil,
    scrollContentLeftOffset = 0,
    scrollContentRightOffset = 0,
    scrollOffset = 0,
    desiredScrollOffset = 0,
    scrollMaxOffset = 0,
    updatingScrollbar = false,
    deferredRefreshScheduled = false,
    pendingDeferredOffset = nil,
    initFullRefreshScheduled = false,
    questContainer = nil,
    endeavorContainer = nil,
    achievementContainer = nil,
    goldenContainer = nil,
    contentStack = nil,
    headerBar = nil,
    footerBar = nil,
    backdrop = nil,
    window = nil,
    layout = nil,
    appearance = nil,
    features = nil,
    windowBars = nil,
    hostSettings = nil,
    anchorWarnings = {
        questMissing = false,
        endeavorMissing = false,
        achievementMissing = false,
        goldenMissing = false,
    },
    sectionHidden = {
        quest = nil,
        endeavor = nil,
        achievement = nil,
        golden = nil,
    },
    dragLayer = nil,
    previousDefaultQuestTrackerHidden = nil,
    initializing = false,
    lamPreviewForceVisible = false,
    sceneCallbacks = nil,
    sceneHidden = false,
    handlingBootstrapVisibility = false,
    bootstrapHudVisible = nil,
    bootstrapCursorMode = nil,
    bootstrapCombatState = nil,
    bootstrapSceneCallbacks = nil,
    bootstrapSceneManagerCallbackRegistered = false,
    bootstrapsRegistered = false,
    cursorBootstrapRegistered = false,
    combatBootstrapRegistered = false,
    runtimeInitialized = false,
    isInCombat = false,
    isInHUDScene = true,
    isLAMOpen = false,
    visibilityGates = nil,
    resizeGrip = nil,        -- legacy single grip (unused)
    resizeGrips = nil,       -- collection of resize grips along the full border
    cornerButton = nil,
    cornerTexture = nil,
    cornerHover = false,
    cornerPressed = false,
    collapsed = false,
    cornerExpandFullRefreshPending = false,
    expandedWindowSize = nil,
}

local resizeState = {
    active = false,
    mode = nil,
    allowH = true,
    allowV = true,
}

local function SetResizeCursor(mode)
    if not WINDOW_MANAGER or not WINDOW_MANAGER.SetMouseCursor then
        return
    end

    if mode == "horizontal" then
        if MOUSE_CURSOR_RESIZE_EW then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_EW)
        end
    elseif mode == "vertical" then
        if MOUSE_CURSOR_RESIZE_NS then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_NS)
        end
    elseif mode == "nwse" then
        if MOUSE_CURSOR_RESIZE_NWSE then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_NWSE)
        end
    elseif mode == "nesw" then
        if MOUSE_CURSOR_RESIZE_NESW then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_NESW)
        end
    end
end

local function ResetResizeCursor()
    if not WINDOW_MANAGER or not WINDOW_MANAGER.SetMouseCursor then
        return
    end

    if MOUSE_CURSOR_DO_NOT_CARE then
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    elseif MOUSE_CURSOR_DEFAULT_CURSOR then
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DEFAULT_CURSOR)
    end
end

local function IsHorizontalResizeAllowed()
    state.layout = state.layout or ensureLayoutSettings()
    local layout = state.layout or ensureLayoutSettings()

    return layout.autoGrowH ~= true
end

local function IsVerticalResizeAllowed()
    state.layout = state.layout or ensureLayoutSettings()
    local layout = state.layout or ensureLayoutSettings()

    return layout.autoGrowV ~= true
end

local function IsResizeModeEnabled(mode, allowH, allowV)
    if allowH == nil then
        allowH = IsHorizontalResizeAllowed()
    end
    if allowV == nil then
        allowV = IsVerticalResizeAllowed()
    end

    if mode == "left" or mode == "right" then
        return allowH
    elseif mode == "top" or mode == "bottom" then
        return allowV
    elseif mode == "topleft" or mode == "bottomright" then
        return allowH or allowV
    elseif mode == "topright" or mode == "bottomleft" then
        return allowH or allowV
    else
        return true
    end
end

local lamPreview = {
    active = false,
    windowSettingOnOpen = nil,
    wasWindowVisibleBeforeLAM = nil,
    windowPreviewApplied = false,
}

local ensureSceneFragment
local refreshScroll
local applyViewportPadding
local applyScrollbarSide
local measureTrackerContent
local setScrollOffset
local updateScrollContentAnchors
local anchorContainers
local applyWindowBars
local applyWindowVisibility
local createContainers
local ensureRuntimeInitialized
local ensureBootstraps
local queueRuntimeLayout
local applyBootstrapVisibility
local startWindowDrag
local stopWindowDrag
local getCurrentScrollOffset
local ensureVisibilityGates
local setVisibilityGate
local refreshVisibilityGates
local beginResize
local updateResize
local endResize
local createResizeGrip
local performLocalWindowRefresh
local performFullHostRefresh
local setCollapsed
local ensureCornerButton
local refreshCornerButton
local applyCollapsedVisibility
local updateCornerButtonVisualState
local applyWindowLock

local function getSavedVars()
    return Nvk3UT and Nvk3UT.sv
end

local function snapshotEndeavorExpandedAtInit()
    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if type(runtime) ~= "table" then
        return
    end

    if runtime._endeavorExpandedAtInit ~= nil then
        return
    end

    local sv = getSavedVars()
    local expanded
    local endeavorData = sv and sv.EndeavorData
    if type(endeavorData) == "table" and endeavorData.expanded ~= nil then
        expanded = endeavorData.expanded ~= false
    end

    if expanded == nil then
        expanded = true
    end

    runtime._endeavorExpandedAtInit = expanded
end

local function clamp(value, minimum, maximum)
    if value == nil then
        return minimum
    end
    if value < minimum then
        return minimum
    end
    if value > maximum then
        return maximum
    end
    return value
end

local function cloneTable(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, entry in pairs(value) do
        copy[key] = cloneTable(entry)
    end
    return copy
end

local function numbersDiffer(a, b, tolerance)
    if a == b then
        return false
    end

    if a == nil or b == nil then
        return true
    end

    tolerance = tolerance or 0.01
    return math.abs(a - b) > tolerance
end

local function normalizeColorComponent(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        numeric = fallback ~= nil and fallback or 1
    end
    return clamp(numeric, 0, 1)
end

local function ensureColorComponents(color, defaults)
    local target = color
    if type(target) ~= "table" then
        target = {}
    end

    local defaultColor = defaults or DEFAULT_COLOR_FALLBACK
    target.r = normalizeColorComponent(target.r, defaultColor.r)
    target.g = normalizeColorComponent(target.g, defaultColor.g)
    target.b = normalizeColorComponent(target.b, defaultColor.b)
    target.a = normalizeColorComponent(target.a, defaultColor.a)

    return target
end

local function getDefaultMouseoverHighlightColor(trackerType)
    local defaults = DEFAULT_TRACKER_COLORS[trackerType]
    local color = defaults and defaults.mouseoverHighlightColor or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR
    return {
        r = color.r or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR.r,
        g = color.g or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR.g,
        b = color.b or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR.b,
        a = color.a or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR.a,
    }
end

local function sanitizeGoldenSnapshotComponent(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return nil
    end
    if numeric < 0 then
        numeric = 0
    elseif numeric > 1 then
        numeric = 1
    end
    return numeric
end

local function formatGoldenSnapshotColor(color)
    if type(color) ~= "table" then
        return "nil"
    end

    local r = sanitizeGoldenSnapshotComponent(color.r or color[1])
    local g = sanitizeGoldenSnapshotComponent(color.g or color[2])
    local b = sanitizeGoldenSnapshotComponent(color.b or color[3])
    local a = sanitizeGoldenSnapshotComponent(color.a or color[4] or 1)

    if r == nil and g == nil and b == nil and a == nil then
        return "nil"
    end

    return string.format("%.3f,%.3f,%.3f,%.3f", r or 0, g or 0, b or 0, a or 1)
end

local function logGoldenColorSnapshot(phase, trackerColors)
    local diagnostics = Nvk3UT and Nvk3UT.Diagnostics
    if not (diagnostics and type(diagnostics.DebugIfEnabled) == "function") then
        return
    end

    local entries = {}
    for index = 1, #GOLDEN_COLOR_INIT_ROLES do
        local role = GOLDEN_COLOR_INIT_ROLES[index]
        entries[#entries + 1] = string.format(
            "%s=%s",
            role,
            formatGoldenSnapshotColor(trackerColors and trackerColors[role])
        )
    end

    diagnostics:DebugIfEnabled(
        GOLDEN_COLOR_INIT_TAG,
        string.format(
            "[%s] phase=%s tracker=%s %s",
            GOLDEN_COLOR_INIT_TAG,
            tostring(phase or "raw"),
            GOLDEN_TRACKER_TYPE,
            table.concat(entries, " ")
        )
    )
end

local function ensureTrackerColorConfig(sv, trackerType)
    if not (sv and trackerType) then
        return nil
    end

    sv.appearance = sv.appearance or {}
    local tracker = sv.appearance[trackerType]
    if type(tracker) ~= "table" then
        tracker = {}
        sv.appearance[trackerType] = tracker
    end

    tracker.colors = tracker.colors or {}
    local logGoldenColors = trackerType == GOLDEN_TRACKER_TYPE
    if logGoldenColors then
        logGoldenColorSnapshot("rawSV", tracker.colors)
    end

    local defaults = DEFAULT_TRACKER_COLORS[trackerType]
    if defaults and defaults.colors then
        for role, defaultColor in pairs(defaults.colors) do
            tracker.colors[role] = ensureColorComponents(tracker.colors[role], defaultColor)
        end
    end

    if logGoldenColors then
        logGoldenColorSnapshot("normalized", tracker.colors)
    end

    tracker.mouseoverHighlightColor = ensureColorComponents(
        tracker.mouseoverHighlightColor,
        getDefaultMouseoverHighlightColor(trackerType)
    )

    return tracker
end

local function ensureAppearanceColorDefaults()
    local sv = getSavedVars()
    if not sv then
        return nil
    end

    for trackerType in pairs(DEFAULT_TRACKER_COLORS) do
        ensureTrackerColorConfig(sv, trackerType)
    end

    return sv.appearance
end

local function normalizeCornerPosition(value)
    if type(value) ~= "string" then
        return DEFAULT_CORNER_POSITION
    end

    local normalized = value:upper():gsub("%s+", "_"):gsub("%-", "_")
    if CORNER_ANCHORS[normalized] then
        return normalized
    end

    return DEFAULT_CORNER_POSITION
end

local function normalizeScrollbarSide(value)
    if type(value) ~= "string" then
        return DEFAULT_HOST_SETTINGS.scrollbarSide
    end

    local normalized = string.lower(value)
    if normalized == "left" or normalized == "right" then
        return normalized
    end

    return DEFAULT_HOST_SETTINGS.scrollbarSide
end

local function normalizeContentAlign(value)
    if type(value) ~= "string" then
        return DEFAULT_HOST_SETTINGS.contentAlign
    end

    local normalized = string.lower(value)
    if normalized == "left" or normalized == "right" then
        return normalized
    end

    return DEFAULT_HOST_SETTINGS.contentAlign
end

local function getDefaultSectionOrder()
    local layout = Nvk3UT and Nvk3UT.TrackerHostLayout
    if layout and type(layout.GetDefaultSectionOrder) == "function" then
        local ok, order = pcall(layout.GetDefaultSectionOrder)
        if ok and type(order) == "table" then
            return order
        end
    end

    return cloneTable(DEFAULT_SECTION_ORDER_KEYS)
end

local function normalizeSectionOrder(order)
    local normalized = {}
    local seen = {}

    if type(order) == "table" then
        for _, key in ipairs(order) do
            if SECTION_KEY_TO_ID[key] and not seen[key] then
                normalized[#normalized + 1] = key
                seen[key] = true
            end
        end
    end

    for _, key in ipairs(getDefaultSectionOrder()) do
        if not seen[key] then
            normalized[#normalized + 1] = key
            seen[key] = true
        end
    end

    return normalized
end

local function ensureHostSettings()
    local sv = getSavedVars()
    if not sv then
        return cloneTable(DEFAULT_HOST_SETTINGS)
    end

    sv.Settings = sv.Settings or {}
    sv.Settings.Host = sv.Settings.Host or {}

    local hostSettings = sv.Settings.Host
    if hostSettings.HideInCombat == nil then
        hostSettings.HideInCombat = DEFAULT_HOST_SETTINGS.HideInCombat
    else
        hostSettings.HideInCombat = hostSettings.HideInCombat == true
    end

    if hostSettings.CornerButtonEnabled == nil then
        hostSettings.CornerButtonEnabled = DEFAULT_HOST_SETTINGS.CornerButtonEnabled
    else
        hostSettings.CornerButtonEnabled = hostSettings.CornerButtonEnabled ~= false
    end

    hostSettings.CornerPosition = normalizeCornerPosition(hostSettings.CornerPosition)
    hostSettings.contentAlign = normalizeContentAlign(hostSettings.contentAlign)
    hostSettings.scrollbarSide = normalizeScrollbarSide(hostSettings.scrollbarSide)
    hostSettings.sectionOrder = normalizeSectionOrder(hostSettings.sectionOrder)

    return hostSettings
end

local function getCornerPosition()
    local sv = getSavedVars()
    if not (sv and sv.Settings and sv.Settings.Host) then
        return DEFAULT_CORNER_POSITION
    end

    local position = sv.Settings.Host.CornerPosition
    if type(position) ~= "string" or position == "" then
        return DEFAULT_CORNER_POSITION
    end

    return normalizeCornerPosition(position)
end

local function isCornerButtonEnabled()
    local hostSettings = state and state.hostSettings
    if not hostSettings then
        local sv = getSavedVars()
        hostSettings = sv and sv.Settings and sv.Settings.Host
    end

    if hostSettings and hostSettings.CornerButtonEnabled ~= nil then
        return hostSettings.CornerButtonEnabled ~= false
    end

    return true
end

local function getHostSettings()
    if state.hostSettings == nil then
        state.hostSettings = ensureHostSettings()
    end

    return state.hostSettings
end

local function getScrollbarSide()
    local hostSettings = getHostSettings()
    return normalizeScrollbarSide(hostSettings and hostSettings.scrollbarSide)
end

local function getContentAlign()
    local hostSettings = getHostSettings()
    return normalizeContentAlign(hostSettings and hostSettings.contentAlign)
end

local function getDefaultColor(trackerType, role)
    local defaults = DEFAULT_TRACKER_COLORS[trackerType]
    local colors = defaults and defaults.colors or nil
    local color = colors and colors[role] or DEFAULT_COLOR_FALLBACK
    local r = color.r or DEFAULT_COLOR_FALLBACK.r
    local g = color.g or DEFAULT_COLOR_FALLBACK.g
    local b = color.b or DEFAULT_COLOR_FALLBACK.b
    local a = color.a or DEFAULT_COLOR_FALLBACK.a
    return r, g, b, a
end

local function getMouseoverHighlightColor(trackerType)
    local defaultColor = getDefaultMouseoverHighlightColor(trackerType)
    local appearance = ensureAppearanceColorDefaults()
    local tracker = appearance and appearance[trackerType]
    local color = tracker and tracker.mouseoverHighlightColor
    color = ensureColorComponents(color, defaultColor)
    if tracker then
        tracker.mouseoverHighlightColor = color
    end

    return color.r, color.g, color.b, color.a
end

local function isWindowOptionEnabled()
    if state.window and state.window.visible ~= nil then
        return state.window.visible ~= false
    end

    local sv = getSavedVars()
    local general = sv and sv.General
    local window = general and general.window
    if window and window.visible ~= nil then
        return window.visible ~= false
    end

    return true
end

local function migrateAppearanceSettings(target)
    local sv = getSavedVars()
    if not sv then
        return
    end

    local quest = sv.QuestTracker and sv.QuestTracker.background
    local achievement = sv.AchievementTracker and sv.AchievementTracker.background

    local function applySource(source)
        if type(source) ~= "table" then
            return false
        end

        local used = false
        if source.enabled ~= nil and target.enabled == nil then
            target.enabled = source.enabled ~= false
            used = true
        end
        if source.alpha ~= nil and target.alpha == nil then
            target.alpha = clamp(tonumber(source.alpha) or DEFAULT_APPEARANCE.alpha, 0, 1)
            used = true
        end
        if source.edgeAlpha ~= nil and target.edgeAlpha == nil then
            target.edgeAlpha = clamp(tonumber(source.edgeAlpha) or DEFAULT_APPEARANCE.edgeAlpha, 0, 1)
            used = true
        end
        if source.padding ~= nil and target.padding == nil then
            local padding = tonumber(source.padding) or DEFAULT_APPEARANCE.padding
            target.padding = math.max(0, math.floor(padding + 0.5))
            used = true
        end
        return used
    end

    local migrated = false
    migrated = applySource(quest) or migrated
    migrated = applySource(achievement) or migrated

    if migrated then
        target.edgeEnabled = target.edgeEnabled ~= false and (target.edgeAlpha or DEFAULT_APPEARANCE.edgeAlpha) > 0
    end
end

local function ensureAppearanceSettings()
    local sv = getSavedVars()
    if not sv then
        return cloneTable(DEFAULT_APPEARANCE)
    end

    sv.General = sv.General or {}
    sv.General.Appearance = sv.General.Appearance or {}

    local appearance = sv.General.Appearance
    if not appearance._migrated then
        migrateAppearanceSettings(appearance)
        appearance._migrated = true
    end

    if appearance.enabled == nil then
        appearance.enabled = DEFAULT_APPEARANCE.enabled
    end
    appearance.alpha = clamp(tonumber(appearance.alpha) or DEFAULT_APPEARANCE.alpha, 0, 1)
    if appearance.edgeEnabled == nil then
        appearance.edgeEnabled = DEFAULT_APPEARANCE.edgeEnabled
    else
        appearance.edgeEnabled = appearance.edgeEnabled ~= false
    end
    appearance.edgeAlpha = clamp(tonumber(appearance.edgeAlpha) or DEFAULT_APPEARANCE.edgeAlpha, 0, 1)
    local thickness = tonumber(appearance.edgeThickness)
    if thickness == nil then
        thickness = DEFAULT_APPEARANCE.edgeThickness
    end
    appearance.edgeThickness = math.max(1, math.floor(thickness + 0.5))
    local padding = tonumber(appearance.padding)
    if padding == nil then
        padding = DEFAULT_APPEARANCE.padding
    end
    appearance.padding = math.max(0, math.floor(padding + 0.5))
    local cornerRadius = tonumber(appearance.cornerRadius)
    if cornerRadius == nil then
        cornerRadius = DEFAULT_APPEARANCE.cornerRadius
    end
    appearance.cornerRadius = math.max(0, math.floor(cornerRadius + 0.5))
    if type(appearance.theme) ~= "string" or appearance.theme == "" then
        appearance.theme = DEFAULT_APPEARANCE.theme
    else
        appearance.theme = string.lower(appearance.theme)
    end

    return appearance
end

local function migrateHostSettings(general)
    local sv = getSavedVars()
    if not sv or type(general) ~= "table" then
        return
    end

    if general._hostMigrated then
        return
    end

    general.window = general.window or {}
    general.features = general.features or {}
    general.layout = general.layout or {}

    local quest = sv.QuestTracker
    local achievement = sv.AchievementTracker

    if general.window.locked == nil then
        if quest and quest.lock ~= nil then
            general.window.locked = quest.lock and true or false
        elseif achievement and achievement.lock ~= nil then
            general.window.locked = achievement.lock and true or false
        end
    end

    if general.features.hideDefaultQuestTracker == nil and quest and quest.hideDefault ~= nil then
        general.features.hideDefaultQuestTracker = quest.hideDefault and true or false
    end

    if general.hideBaseQuestTracker == nil then
        if general.features.hideDefaultQuestTracker ~= nil then
            general.hideBaseQuestTracker = general.features.hideDefaultQuestTracker == true
        elseif quest and quest.hideDefault ~= nil then
            general.hideBaseQuestTracker = quest.hideDefault and true or false
        end
    end

    if general.layout.autoGrowV == nil then
        if quest and quest.autoGrowV ~= nil then
            general.layout.autoGrowV = quest.autoGrowV == true
        elseif achievement and achievement.autoGrowV ~= nil then
            general.layout.autoGrowV = achievement.autoGrowV == true
        end
    end

    if general.layout.autoGrowH == nil then
        if quest and quest.autoGrowH ~= nil then
            general.layout.autoGrowH = quest.autoGrowH and true or false
        elseif achievement and achievement.autoGrowH ~= nil then
            general.layout.autoGrowH = achievement.autoGrowH and true or false
        end
    end

    general._hostMigrated = true
end

local function ensureFeatureSettings()
    local sv = getSavedVars()
    if not sv then
        return { hideDefaultQuestTracker = false }
    end

    sv.General = sv.General or {}
    migrateHostSettings(sv.General)
    sv.General.features = sv.General.features or {}

    local features = sv.General.features
    if features.hideDefaultQuestTracker == nil then
        features.hideDefaultQuestTracker = sv.General.hideBaseQuestTracker
    end

    features.hideDefaultQuestTracker = features.hideDefaultQuestTracker == true

    return features
end

local function ensureLayoutSettings()
    local sv = getSavedVars()
    if not sv then
        return cloneTable(DEFAULT_LAYOUT)
    end

    sv.General = sv.General or {}
    migrateHostSettings(sv.General)
    sv.General.layout = sv.General.layout or {}

    local layout = sv.General.layout

    if layout.autoGrowV == nil then
        layout.autoGrowV = DEFAULT_LAYOUT.autoGrowV
    else
        layout.autoGrowV = layout.autoGrowV == true
    end

    if layout.autoGrowH == nil then
        layout.autoGrowH = DEFAULT_LAYOUT.autoGrowH
    else
        layout.autoGrowH = layout.autoGrowH == true
    end

    local minWidth = tonumber(layout.minWidth)
    if not minWidth then
        minWidth = DEFAULT_LAYOUT.minWidth
    end
    minWidth = math.max(MIN_WIDTH, math.floor(minWidth + 0.5))

    local maxWidth = tonumber(layout.maxWidth)
    if not maxWidth then
        maxWidth = DEFAULT_LAYOUT.maxWidth
    end
    maxWidth = math.max(minWidth, math.floor(maxWidth + 0.5))

    local minHeight = tonumber(layout.minHeight)
    if not minHeight then
        minHeight = DEFAULT_LAYOUT.minHeight
    end
    minHeight = math.max(MIN_HEIGHT, math.floor(minHeight + 0.5))

    local maxHeight = tonumber(layout.maxHeight)
    if not maxHeight then
        maxHeight = DEFAULT_LAYOUT.maxHeight
    end
    maxHeight = math.max(minHeight, math.floor(maxHeight + 0.5))

    layout.minWidth = minWidth
    layout.maxWidth = maxWidth
    layout.minHeight = minHeight
    layout.maxHeight = maxHeight

    return layout
end

local function ensureWindowBarSettings()
    local sv = getSavedVars()
    if not sv then
        return cloneTable(DEFAULT_WINDOW_BARS)
    end

    sv.General = sv.General or {}
    sv.General.WindowBars = sv.General.WindowBars or {}

    local bars = sv.General.WindowBars

    local headerHeight = tonumber(bars.headerHeightPx)
    if headerHeight == nil then
        headerHeight = DEFAULT_WINDOW_BARS.headerHeightPx
    end
    headerHeight = clamp(math.floor(headerHeight + 0.5), 0, MAX_BAR_HEIGHT)
    bars.headerHeightPx = headerHeight

    local footerHeight = tonumber(bars.footerHeightPx)
    if footerHeight == nil then
        footerHeight = DEFAULT_WINDOW_BARS.footerHeightPx
    end
    footerHeight = clamp(math.floor(footerHeight + 0.5), 0, MAX_BAR_HEIGHT)
    bars.footerHeightPx = footerHeight

    return bars
end

local function getEffectiveBarHeights()
    local bars = state.windowBars or ensureWindowBarSettings()
    local headerHeight = clamp(tonumber(bars and bars.headerHeightPx) or DEFAULT_WINDOW_BARS.headerHeightPx, 0, MAX_BAR_HEIGHT)
    local footerHeight = clamp(tonumber(bars and bars.footerHeightPx) or DEFAULT_WINDOW_BARS.footerHeightPx, 0, MAX_BAR_HEIGHT)
    return headerHeight, footerHeight
end

local function ensureWindowSettings()
    local sv = getSavedVars()
    if not sv then
        return cloneTable(DEFAULT_WINDOW)
    end

    sv.General = sv.General or {}
    migrateHostSettings(sv.General)
    sv.General.window = sv.General.window or {}

    local window = sv.General.window
    if type(window.left) ~= "number" then
        window.left = tonumber(window.left) or DEFAULT_WINDOW.left
    end
    if type(window.top) ~= "number" then
        window.top = tonumber(window.top) or DEFAULT_WINDOW.top
    end
    if type(window.width) ~= "number" then
        window.width = tonumber(window.width) or DEFAULT_WINDOW.width
    end
    if type(window.height) ~= "number" then
        window.height = tonumber(window.height) or DEFAULT_WINDOW.height
    end
    if window.locked == nil then
        window.locked = DEFAULT_WINDOW.locked
    else
        window.locked = window.locked == true
    end
    if window.visible == nil then
        window.visible = DEFAULT_WINDOW.visible
    else
        window.visible = window.visible ~= false
    end
    if window.clamp == nil then
        window.clamp = DEFAULT_WINDOW.clamp
    else
        window.clamp = window.clamp ~= false
    end
    if window.onTop == nil then
        window.onTop = DEFAULT_WINDOW.onTop
    else
        window.onTop = window.onTop == true
    end

    return window
end

local function clampWindowToScreen(width, height)
    if not GuiRoot then
        return
    end

    local rootWidth = GuiRoot:GetWidth() or 0
    local rootHeight = GuiRoot:GetHeight() or 0

    local window = state.window
    if not window then
        return
    end

    if window.clamp == false then
        return
    end

    local maxLeft = math.max(0, rootWidth - width)
    local maxTop = math.max(0, rootHeight - height)

    window.left = math.min(math.max(window.left or 0, 0), maxLeft)
    window.top = math.min(math.max(window.top or 0, 0), maxTop)
end

local function saveWindowPosition()
    if not (state.root and state.window) then
        return
    end

    local left = state.root:GetLeft() or state.window.left or 0
    local top = state.root:GetTop() or state.window.top or 0

    state.window.left = math.floor(left + 0.5)
    state.window.top = math.floor(top + 0.5)
end

local function saveWindowSize()
    if not (state.root and state.window) then
        return
    end

    state.layout = ensureLayoutSettings()
    local layout = state.layout

    local minWidth = layout.minWidth or MIN_WIDTH
    local minHeight = layout.minHeight or MIN_HEIGHT
    local maxWidth = layout.maxWidth or math.max(minWidth, state.root:GetWidth() or minWidth)
    local maxHeight = layout.maxHeight or math.max(minHeight, state.root:GetHeight() or minHeight)

    local width = clamp(state.root:GetWidth() or state.window.width or minWidth, minWidth, maxWidth)
    local height = clamp(state.root:GetHeight() or state.window.height or minHeight, minHeight, maxHeight)

    state.window.width = math.floor(width + 0.5)
    state.window.height = math.floor(height + 0.5)
end

startWindowDrag = function()
    if not (state.root and state.window) then
        return
    end

    if state.window.locked then
        return
    end

    state.root:StartMoving()
end

stopWindowDrag = function()
    if not state.root then
        return
    end

    state.root:StopMovingOrResizing()
    saveWindowPosition()
end

local function attachDragHandlers(control)
    if not control then
        return
    end

    control:SetMouseEnabled(true)

    control:SetHandler("OnMouseDown", function(_, button)
        if button ~= LEFT_MOUSE_BUTTON then
            return
        end

        local scrollbar = state.scrollbar
        local mouseOver = WINDOW_MANAGER and WINDOW_MANAGER.GetMouseOverControl and WINDOW_MANAGER:GetMouseOverControl()
        if scrollbar and mouseOver then
            local current = mouseOver
            while current do
                if current == scrollbar then
                    return
                end
                if current.GetParent then
                    current = current:GetParent()
                else
                    break
                end
            end
        end

        startWindowDrag()
    end)

    control:SetHandler("OnMouseUp", function(_, button)
        if button == LEFT_MOUSE_BUTTON then
            stopWindowDrag()
        end
    end)

    control:SetHandler("OnMouseUpOutside", function(_, button)
        if button == LEFT_MOUSE_BUTTON then
            stopWindowDrag()
        end
    end)
end

local function beginResize(mode)
    if not (state.root and state.window) then
        return
    end

    state.window = state.window or ensureWindowSettings()

    if state.window.locked == true then
        return
    end

    local resizeMode = mode or "bottomright"
    local allowH = IsHorizontalResizeAllowed()
    local allowV = IsVerticalResizeAllowed()
    if not IsResizeModeEnabled(resizeMode, allowH, allowV) then
        return
    end

    if type(GetUIMousePosition) ~= "function" then
        return
    end

    local startX, startY = GetUIMousePosition()
    if not (startX and startY) then
        return
    end

    resizeState.active = true
    resizeState.mode = resizeMode
    resizeState.allowH = allowH
    resizeState.allowV = allowV

    if resizeMode == "left" or resizeMode == "right" then
        if allowH then
            SetResizeCursor("horizontal")
        end
    elseif resizeMode == "top" or resizeMode == "bottom" then
        if allowV then
            SetResizeCursor("vertical")
        end
    elseif resizeMode == "topleft" or resizeMode == "bottomright" then
        if allowH and allowV then
            SetResizeCursor("nwse")
        elseif allowH then
            SetResizeCursor("horizontal")
        elseif allowV then
            SetResizeCursor("vertical")
        end
    elseif resizeMode == "topright" or resizeMode == "bottomleft" then
        if allowH and allowV then
            SetResizeCursor("nesw")
        elseif allowH then
            SetResizeCursor("horizontal")
        elseif allowV then
            SetResizeCursor("vertical")
        end
    end
    resizeState.startX = startX
    resizeState.startY = startY
    resizeState.startWidth = state.root:GetWidth() or state.window.width or DEFAULT_WINDOW.width
    resizeState.startHeight = state.root:GetHeight() or state.window.height or DEFAULT_WINDOW.height
    resizeState.startLeft = state.root:GetLeft() or state.window.left or DEFAULT_WINDOW.left
    resizeState.startTop = state.root:GetTop() or state.window.top or DEFAULT_WINDOW.top
end

local function updateResize()
    if not (resizeState.active and state.root) then
        return
    end

    if type(GetUIMousePosition) ~= "function" then
        return
    end

    local currentX, currentY = GetUIMousePosition()
    if not (currentX and currentY) then
        return
    end

    state.layout = state.layout or ensureLayoutSettings()
    state.window = state.window or ensureWindowSettings()

    local layout = state.layout
    local window = state.window

    local minWidth = layout.minWidth or MIN_WIDTH
    local minHeight = layout.minHeight or MIN_HEIGHT
    local maxWidth = layout.maxWidth or math.max(minWidth, resizeState.startWidth or minWidth)
    local maxHeight = layout.maxHeight or math.max(minHeight, resizeState.startHeight or minHeight)

    local dx = currentX - (resizeState.startX or currentX)
    local dy = currentY - (resizeState.startY or currentY)

    local startWidth = resizeState.startWidth or window.width or minWidth
    local startHeight = resizeState.startHeight or window.height or minHeight
    local startLeft = resizeState.startLeft or state.root:GetLeft() or window.left or 0
    local startTop = resizeState.startTop or state.root:GetTop() or window.top or 0

    local mode = resizeState.mode or "bottomright"
    local allowH = resizeState.allowH ~= false
    local allowV = resizeState.allowV ~= false

    local newWidth = startWidth
    local newHeight = startHeight
    local newLeft = startLeft
    local newTop = startTop

    if mode == "right" then
        if allowH then
            newWidth = clamp(startWidth + dx, minWidth, maxWidth)
        end
    elseif mode == "bottom" then
        if allowV then
            newHeight = clamp(startHeight + dy, minHeight, maxHeight)
        end
    elseif mode == "left" then
        if allowH then
            local targetWidth = clamp(startWidth - dx, minWidth, maxWidth)
            local rightEdge = startLeft + startWidth
            newWidth = targetWidth
            newLeft = rightEdge - targetWidth
        end
    elseif mode == "top" then
        if allowV then
            local targetHeight = clamp(startHeight - dy, minHeight, maxHeight)
            local bottomEdge = startTop + startHeight
            newHeight = targetHeight
            newTop = bottomEdge - targetHeight
        end
    elseif mode == "topleft" then
        local rightEdge = startLeft + startWidth
        local bottomEdge = startTop + startHeight
        if allowH then
            local targetWidth = clamp(startWidth - dx, minWidth, maxWidth)
            newWidth = targetWidth
            newLeft = rightEdge - targetWidth
        end
        if allowV then
            local targetHeight = clamp(startHeight - dy, minHeight, maxHeight)
            newHeight = targetHeight
            newTop = bottomEdge - targetHeight
        end
    elseif mode == "topright" then
        local bottomEdge = startTop + startHeight
        if allowH then
            newWidth = clamp(startWidth + dx, minWidth, maxWidth)
        end
        if allowV then
            local targetHeight = clamp(startHeight - dy, minHeight, maxHeight)
            newHeight = targetHeight
            newTop = bottomEdge - targetHeight
        end
    elseif mode == "bottomleft" then
        local rightEdge = startLeft + startWidth
        if allowH then
            local targetWidth = clamp(startWidth - dx, minWidth, maxWidth)
            newWidth = targetWidth
            newLeft = rightEdge - targetWidth
        end
        if allowV then
            newHeight = clamp(startHeight + dy, minHeight, maxHeight)
        end
    else -- bottomright / fallback corner behavior
        if allowH then
            newWidth = clamp(startWidth + dx, minWidth, maxWidth)
        end
        if allowV then
            newHeight = clamp(startHeight + dy, minHeight, maxHeight)
        end
    end

    window.width = math.floor(newWidth + 0.5)
    window.height = math.floor(newHeight + 0.5)
    window.left = math.floor(newLeft + 0.5)
    window.top = math.floor(newTop + 0.5)

    clampWindowToScreen(window.width, window.height)

    local anchorParent = GuiRoot or state.root:GetParent() or state.root
    local finalLeft = window.left or newLeft
    local finalTop = window.top or newTop

    state.root:ClearAnchors()
    state.root:SetAnchor(TOPLEFT, anchorParent, TOPLEFT, finalLeft, finalTop)
    state.root:SetDimensions(window.width, window.height)
end

local function endResize()
    if not resizeState.active then
        return
    end

    resizeState.active = false
    resizeState.mode = nil
    resizeState.startX = nil
    resizeState.startY = nil
    resizeState.startWidth = nil
    resizeState.startHeight = nil
    resizeState.startLeft = nil
    resizeState.startTop = nil
    resizeState.allowH = true
    resizeState.allowV = true

    ResetResizeCursor()

    if state.root and state.window then
        if saveWindowSize then
            saveWindowSize()
        end

        if saveWindowPosition then
            saveWindowPosition()
        end

        if performFullHostRefresh then
            performFullHostRefresh("manualResize")
        end
    end
end

if EVENT_MANAGER and EVENT_GLOBAL_MOUSE_UP then
    EVENT_MANAGER:RegisterForEvent(RESIZE_EVENT_NAMESPACE, EVENT_GLOBAL_MOUSE_UP, function(_, button)
        if button == LEFT_MOUSE_BUTTON and resizeState.active then
            endResize()
        end
    end)
end

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils.IsDebugEnabled()
    end
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end
    local addon = Nvk3UT
    if addon and type(addon.IsDebugEnabled) == "function" then
        return addon:IsDebugEnabled()
    end
    return false
end

local function debugLog(...)
    if not isDebugEnabled() then
        return
    end

    local prefix = string.format("[%s]", addonName .. ".TrackerHost")
    if d then
        d(prefix, ...)
    elseif print then
        print(prefix, ...)
    end
end

local function diagnosticsDebug(fmt, ...)
    local diagnostics = Nvk3UT and Nvk3UT.Diagnostics
    if diagnostics and type(diagnostics.Debug) == "function" then
        diagnostics.Debug(fmt, ...)
        return
    end

    if fmt ~= nil then
        debugLog(string.format(tostring(fmt), ...))
    end
end

local function visibilityDebug(fmt, ...)
    local diagnostics = Nvk3UT and Nvk3UT.Diagnostics
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled("TrackerHost", fmt, ...)
        return
    end

    diagnosticsDebug(fmt, ...)
end

local loggedTopRightChevronVisual = false

local function safeCall(fn, ...)
    local safe = Nvk3UT and Nvk3UT.SafeCall
    if type(safe) == "function" then
        return safe(fn, ...)
    end

    if type(fn) ~= "function" then
        return nil
    end

    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end

    return nil
end

local function getRuntime()
    local addon = Nvk3UT
    if type(addon) ~= "table" then
        return nil
    end

    local runtime = addon.TrackerRuntime
    if type(runtime) ~= "table" then
        return nil
    end

    return runtime
end

local function callRuntime(methodName, ...)
    local runtime = getRuntime()
    if not runtime then
        return
    end

    local method = runtime[methodName]
    if type(method) ~= "function" then
        return
    end

    local args = { ... }
    safeCall(function()
        method(runtime, unpack(args))
    end)
end

queueRuntimeLayout = function(reason)
    if reason then
        callRuntime("QueueLayout", reason)
        return
    end

    callRuntime("QueueLayout")
end

local function requestPendingFullRebuild()
    local runtime = getRuntime()
    if not runtime then
        return
    end

    local consume = runtime.ConsumePendingFullRebuild or runtime.consumePendingFullRebuild
    if type(consume) ~= "function" then
        return
    end

    local rebuild = (Nvk3UT and Nvk3UT.Rebuild) or _G.Nvk3UT_Rebuild
    local rebuildAll = rebuild and (rebuild.All or rebuild.all)
    if type(rebuildAll) ~= "function" then
        return
    end

    local hasPending = runtime.HasPendingFullRebuild or runtime.hasPendingFullRebuild
    if type(hasPending) == "function" then
        local pending = hasPending(runtime)
        if pending ~= true then
            return
        end
    end

    local reason = consume(runtime)
    if not reason then
        return
    end

    local context = "pendingVisible"
    if type(reason) == "string" and reason ~= "" then
        context = string.format("%s:%s", context, reason)
    end

    safeCall(function()
        rebuildAll(context)
    end)
end

local function triggerDeferredFullRebuildOnVisible()
    local runtime = getRuntime()
    if not runtime or runtime.needsFullRebuildOnVisible ~= true then
        return
    end

    runtime.needsFullRebuildOnVisible = false

    local function markDirty(controller)
        if controller and controller.RequestRefresh then
            safeCall(controller.RequestRefresh, controller, "TrackerHost:deferredRebuild")
        elseif controller and controller.MarkDirty then
            safeCall(controller.MarkDirty, controller)
        end
    end

    markDirty(Nvk3UT and Nvk3UT.QuestTrackerController)
    markDirty(Nvk3UT and Nvk3UT.EndeavorTrackerController)
    markDirty(Nvk3UT and Nvk3UT.AchievementTrackerController)
    if Nvk3UT and Nvk3UT.GoldenTrackerController then
        markDirty(Nvk3UT.GoldenTrackerController)
    end

    if runtime.QueueDirty then
        safeCall(function()
            runtime:QueueDirty("layout")
        end)
    end

    local rebuild = (Nvk3UT and Nvk3UT.Rebuild) or _G.Nvk3UT_Rebuild
    local rebuildAll = rebuild and (rebuild.All or rebuild.all)
    if type(rebuildAll) == "function" and TrackerHost.IsVisible() then
        safeCall(function()
            rebuildAll("sceneVisible:needsFullRebuild")
        end)
    end
end

local function requestHostFullRebuild(context)
    local addonRoot = type(Nvk3UT) == "table" and Nvk3UT or nil
    if addonRoot and addonRoot._rebuild_lock then
        return
    end

    local rebuild = (addonRoot and addonRoot.Rebuild) or _G.Nvk3UT_Rebuild
    local rebuildAll = rebuild and rebuild.All
    if type(rebuildAll) == "function" then
        safeCall(rebuildAll, context or "hostVisible")
    end
end

ensureVisibilityGates = function()
    if not state.visibilityGates then
        state.visibilityGates = {
            scene = false,
            combat = false,
            lam = false,
        }
    end

    return state.visibilityGates
end

setVisibilityGate = function(gateName, value)
    if type(gateName) ~= "string" then
        return false
    end

    local gates = ensureVisibilityGates()
    local normalized = value == true

    if gates[gateName] == normalized then
        return false
    end

    gates[gateName] = normalized
    return true
end

refreshVisibilityGates = function(hostSettings)
    local gates = ensureVisibilityGates()

    gates.scene = state.isInHUDScene ~= true

    local hideInCombatSetting = false
    if hostSettings and hostSettings.HideInCombat == true then
        hideInCombatSetting = true
    end

    gates.combat = hideInCombatSetting and state.isInCombat == true or false
    gates.lam = state.isLAMOpen == true

    return gates
end

local function resolveQuestTrackerEnabled()
    local tracker = Nvk3UT and Nvk3UT.QuestTracker
    if tracker and tracker.IsActive then
        local ok, active = pcall(tracker.IsActive)
        if ok and active ~= nil then
            return active ~= false
        end
    end

    local saved = getSavedVars()
    local quest = saved and saved.QuestTracker
    if type(quest) == "table" and quest.active ~= nil then
        return quest.active ~= false
    end

    return true
end

local function resolveAchievementTrackerEnabled()
    local tracker = Nvk3UT and Nvk3UT.AchievementTracker
    if tracker and tracker.IsActive then
        local ok, active = pcall(tracker.IsActive)
        if ok and active ~= nil then
            return active ~= false
        end
    end

    local saved = getSavedVars()
    local achievement = saved and saved.AchievementTracker
    if type(achievement) == "table" and achievement.active ~= nil then
        return achievement.active ~= false
    end

    return true
end

local function resolveEndeavorTrackerEnabled()
    local saved = getSavedVars()
    local endeavorConfig = saved and saved.Endeavor
    if type(endeavorConfig) == "table" and endeavorConfig.Enabled ~= nil then
        return endeavorConfig.Enabled ~= false
    end

    local achievement = saved and saved.AchievementTracker
    if type(achievement) == "table" and achievement.active ~= nil then
        return achievement.active ~= false
    end

    return true
end

local function resolveGoldenTrackerEnabled()
    local saved = getSavedVars()
    local goldenConfig = saved and saved.Golden
    if type(goldenConfig) == "table" and goldenConfig.Enabled ~= nil then
        return goldenConfig.Enabled ~= false
    end

    local defaultsRoot = saved and saved.TrackerDefaults
    local goldenDefaults = defaultsRoot and defaultsRoot.GoldenDefaults
    if type(goldenDefaults) == "table" and goldenDefaults.Enabled ~= nil then
        return goldenDefaults.Enabled ~= false
    end

    return true
end

local function resolveTrackerEnabledStates()
    return {
        quest = resolveQuestTrackerEnabled(),
        endeavor = resolveEndeavorTrackerEnabled(),
        achievement = resolveAchievementTrackerEnabled(),
        golden = resolveGoldenTrackerEnabled(),
    }
end

local function applyTrackerSectionVisibility()
    local containers = {
        quest = state.questContainer,
        endeavor = state.endeavorContainer,
        achievement = state.achievementContainer,
        golden = state.goldenContainer,
    }

    local enabledStates = resolveTrackerEnabledStates()
    local changed = false
    local visibilityCache = state.sectionHidden or {}
    state.sectionHidden = visibilityCache

    if isDebugEnabled() then
        visibilityDebug(
            "TrackerVisibility flags: quest=%s endeavor=%s achievement=%s golden=%s",
            tostring(enabledStates.quest),
            tostring(enabledStates.endeavor),
            tostring(enabledStates.achievement),
            tostring(enabledStates.golden)
        )
    end

    local function apply(sectionId)
        local container = containers[sectionId]
        local enabled = enabledStates[sectionId] ~= false
        local hidden = not enabled

        if not (container and container.SetHidden) then
            if isDebugEnabled() then
                visibilityDebug("TrackerVisibility: %s container missing", sectionId)
            end
            visibilityCache[sectionId] = hidden
            return
        end

        local current = safeCall(function()
            if container.IsHidden then
                return container:IsHidden()
            end
            return nil
        end)

        if current ~= hidden then
            container:SetHidden(hidden)
            changed = true
        end

        visibilityCache[sectionId] = hidden

        if isDebugEnabled() then
            local effectiveHidden = hidden
            local probe = safeCall(function()
                if container.IsHidden then
                    return container:IsHidden()
                end
                return nil
            end)
            if probe ~= nil then
                effectiveHidden = probe
            end
            visibilityDebug(
                "TrackerVisibility: %s hidden=%s (enabled=%s)",
                sectionId,
                tostring(effectiveHidden),
                tostring(enabled)
            )
        end
    end

    apply("quest")
    apply("endeavor")
    apply("achievement")
    apply("golden")

    return changed
end

function TrackerHost.SetCombatState(selfOrFlag, maybeFlag)
    local targetFlag
    if selfOrFlag == TrackerHost then
        targetFlag = maybeFlag
    else
        targetFlag = selfOrFlag
    end

    local normalized = targetFlag == true
    local previous = state.isInCombat == true
    if previous == normalized then
        return false
    end

    state.isInCombat = normalized

    local hostSettings = getHostSettings()
    setVisibilityGate("combat", hostSettings and hostSettings.HideInCombat == true and normalized)

    visibilityDebug("Host combat: %s -> ApplyVisibilityRules()", tostring(normalized))

    local visibilityChanged = TrackerHost.ApplyVisibilityRules()

    callRuntime("SetCombatState", normalized)

    return visibilityChanged == true
end

local BOOTSTRAP_NAMESPACE = addonName .. "_TrackerHostBootstrap"

ensureRuntimeInitialized = function()
    if state.runtimeInitialized then
        return
    end

    if not state.root then
        return
    end

    local runtime = getRuntime()
    if not runtime or type(runtime.Init) ~= "function" then
        return
    end

    local initialized = false
    safeCall(function()
        runtime:Init(state.root)
        initialized = true
    end)

    if initialized then
        state.runtimeInitialized = true
        visibilityDebug("TrackerHost runtime initialized (root=%s)", tostring(state.root))
    end
end

local function isGameHUDActive()
    local manager = SCENE_MANAGER
    if manager and type(manager.IsShowing) == "function" then
        if manager:IsShowing("hud") then
            return true
        end
        if manager:IsShowing("hudui") then
            return true
        end
        return false
    end

    return true
end

local function normalizeCursorMode(currentMode)
    if type(currentMode) == "boolean" then
        return currentMode
    end

    if type(currentMode) == "number" then
        if CURSOR_MODE_GAME ~= nil then
            return currentMode ~= CURSOR_MODE_GAME
        end
        return currentMode ~= 0
    end

    if SCENE_MANAGER and type(SCENE_MANAGER.IsInUIMode) == "function" then
        return SCENE_MANAGER:IsInUIMode()
    end

    if type(GetCursorMode) == "function" then
        local mode = GetCursorMode()
        if CURSOR_MODE_GAME ~= nil then
            return mode ~= CURSOR_MODE_GAME
        end
        return mode ~= 0
    end

    return false
end

local function updateCursorModeState(isInCursorMode)
    local normalized = isInCursorMode == true
    if normalized ~= true and normalized ~= false then
        normalized = normalizeCursorMode(isInCursorMode)
    end

    if state.bootstrapCursorMode == normalized then
        return
    end

    state.bootstrapCursorMode = normalized
    visibilityDebug("TrackerHost cursor mode changed: %s", tostring(normalized))
    callRuntime("SetCursorMode", normalized)
end

local function updateCombatState(inCombat)
    local normalized = inCombat == true
    if state.bootstrapCombatState == normalized and state.isInCombat == normalized then
        return
    end

    state.bootstrapCombatState = normalized
    TrackerHost.SetCombatState(normalized)
end

-- TEMP_BOOTSTRAP: Scene/HUD/Cursor/Combat forwarding only; no visibility toggles. Remove in EVENTS_012/013/014_SWITCH.
local function applyBootstrapVisibility(host)
    if not host then
        return
    end

    local shouldShow = isGameHUDActive()
    if state.bootstrapHudVisible == shouldShow and state.isInHUDScene == shouldShow then
        return
    end

    state.bootstrapHudVisible = shouldShow
    state.isInHUDScene = shouldShow
    setVisibilityGate("scene", not shouldShow)
    visibilityDebug("TrackerHost HUD visibility changed: %s", tostring(shouldShow))

    if TrackerHost.ApplyVisibilityRules() then
        callRuntime("RequestFullRebuild", "hudVisible")

        if type(zo_callLater) == "function" then
            zo_callLater(function()
                callRuntime("RequestFullRebuild", "hudVisible:deferred")
            end, 1)
        end
    end
end

local function registerHudScene(host, scene, sceneName)
    if not scene then
        diagnosticsDebug("HUD bootstrap scene missing: %s", tostring(sceneName))
        return
    end

    if type(scene.RegisterCallback) ~= "function" then
        diagnosticsDebug("HUD bootstrap scene lacks RegisterCallback: %s", tostring(sceneName))
        return
    end

    state.bootstrapSceneCallbacks = state.bootstrapSceneCallbacks or {}
    if state.bootstrapSceneCallbacks[scene] then
        return
    end

    local function onSceneStateChange()
        safeCall(function()
            applyBootstrapVisibility(host)
        end)
    end

    local ok, message = pcall(scene.RegisterCallback, scene, "StateChange", onSceneStateChange)
    if not ok then
        diagnosticsDebug("Failed to register HUD bootstrap callback: %s", tostring(message))
        return
    end

    state.bootstrapSceneCallbacks[scene] = onSceneStateChange
end

local function registerSceneManagerCallback(host)
    if state.bootstrapSceneManagerCallbackRegistered then
        return
    end

    local manager = SCENE_MANAGER
    if not manager then
        diagnosticsDebug("HUD bootstrap missing SCENE_MANAGER")
        return
    end

    if type(manager.RegisterCallback) ~= "function" then
        diagnosticsDebug("HUD bootstrap scene manager lacks RegisterCallback")
        return
    end

    local function onSceneStateChanged()
        safeCall(function()
            applyBootstrapVisibility(host)
        end)
    end

    local ok, message = pcall(manager.RegisterCallback, manager, "SceneStateChanged", onSceneStateChanged)
    if not ok then
        diagnosticsDebug("Failed to register HUD bootstrap global callback: %s", tostring(message))
        return
    end

    state.bootstrapSceneManagerCallbackRegistered = true
end

local function ensureHudBootstrap()
    -- TEMP_BOOTSTRAP: Scene/HUD/Cursor/Combat forwarding only; no visibility toggles. Remove in EVENTS_012/013/014_SWITCH.
    local host = TrackerHost
    registerHudScene(host, HUD_SCENE, "HUD_SCENE")
    registerHudScene(host, HUD_UI_SCENE, "HUD_UI_SCENE")

    if SCENE_MANAGER and type(SCENE_MANAGER.GetScene) == "function" then
        registerHudScene(host, SCENE_MANAGER:GetScene("hud"), "hud")
        registerHudScene(host, SCENE_MANAGER:GetScene("hudui"), "hudui")
    end

    registerSceneManagerCallback(host)

    applyBootstrapVisibility(host)
end

local function cursorModeEventHandler(_, currentMode)
    updateCursorModeState(normalizeCursorMode(currentMode))
end

local function ensureCursorBootstrap()
    if state.cursorBootstrapRegistered then
        return
    end

    if not EVENT_MANAGER or EVENT_CURSOR_MODE_CHANGED == nil then
        return
    end

    -- TEMP_BOOTSTRAP: Scene/HUD/Cursor/Combat forwarding only; no visibility toggles. Remove in EVENTS_012/013/014_SWITCH.
    local eventName = BOOTSTRAP_NAMESPACE .. "_Cursor"
    local ok, message = pcall(EVENT_MANAGER.RegisterForEvent, EVENT_MANAGER, eventName, EVENT_CURSOR_MODE_CHANGED, cursorModeEventHandler)
    if not ok then
        diagnosticsDebug("Failed to register cursor bootstrap: %s", tostring(message))
        return
    end

    state.cursorBootstrapRegistered = true
    updateCursorModeState(normalizeCursorMode(nil))
end

local function combatStateEventHandler(_, inCombat)
    updateCombatState(inCombat)
end

local function ensureCombatBootstrap()
    if state.combatBootstrapRegistered then
        return
    end

    if not EVENT_MANAGER or EVENT_PLAYER_COMBAT_STATE == nil then
        return
    end

    -- TEMP_BOOTSTRAP: Scene/HUD/Cursor/Combat forwarding only; no visibility toggles. Remove in EVENTS_012/013/014_SWITCH.
    local eventName = BOOTSTRAP_NAMESPACE .. "_Combat"
    local ok, message = pcall(EVENT_MANAGER.RegisterForEvent, EVENT_MANAGER, eventName, EVENT_PLAYER_COMBAT_STATE, combatStateEventHandler)
    if not ok then
        diagnosticsDebug("Failed to register combat bootstrap: %s", tostring(message))
        return
    end

    state.combatBootstrapRegistered = true

    local initialCombat = false
    if type(IsUnitInCombat) == "function" then
        local success, result = pcall(IsUnitInCombat, "player")
        if success then
            initialCombat = result == true
        end
    end

    updateCombatState(initialCombat)
end

ensureBootstraps = function()
    if state.bootstrapsRegistered then
        return
    end

    state.bootstrapsRegistered = true

    ensureHudBootstrap()
    ensureCursorBootstrap()
    ensureCombatBootstrap()
end

setScrollOffset = function(rawOffset, skipScrollbarUpdate)
    local maxOffset = state.scrollMaxOffset or 0
    if rawOffset == nil then
        rawOffset = 0
    end

    maxOffset = math.max(0, maxOffset)
    rawOffset = math.max(0, rawOffset)

    local previousActual = state.scrollOffset or 0
    local previousDesired = state.desiredScrollOffset or previousActual

    local offset = rawOffset
    if offset > maxOffset then
        offset = maxOffset
    end

    state.desiredScrollOffset = rawOffset
    state.scrollOffset = offset

    local actualChanged = math.abs(previousActual - offset) >= 0.01
    local desiredChanged = math.abs(previousDesired - rawOffset) >= 0.01

    if not (actualChanged or desiredChanged) then
        if not skipScrollbarUpdate and state.scrollbar and state.scrollbar.SetValue then
            local current = state.scrollbar.GetValue and state.scrollbar:GetValue() or 0
            if math.abs(current - offset) >= 0.01 then
                state.updatingScrollbar = true
                state.scrollbar:SetValue(offset)
                state.updatingScrollbar = false
            end
        end
        return offset
    end

    updateScrollContentAnchors()

    if not skipScrollbarUpdate and state.scrollbar and state.scrollbar.SetValue then
        local current = state.scrollbar.GetValue and state.scrollbar:GetValue() or 0
        if math.abs(current - offset) >= 0.01 then
            state.updatingScrollbar = true
            state.scrollbar:SetValue(offset)
            state.updatingScrollbar = false
        end
    end

    return offset
end

local function adjustScroll(delta)
    local scrollbar = state.scrollbar
    if not (scrollbar and scrollbar.GetMinMax) then
        return
    end

    local minValue, maxValue = scrollbar:GetMinMax()
    if not (minValue and maxValue) then
        return
    end

    local current = state.desiredScrollOffset
    if current == nil then
        current = state.scrollOffset
    end
    if current == nil then
        current = scrollbar.GetValue and scrollbar:GetValue() or 0
    end
    current = current or 0
    local clampedCurrent = current
    if clampedCurrent < minValue then
        clampedCurrent = minValue
    elseif clampedCurrent > maxValue then
        clampedCurrent = maxValue
    end

    local step = 48
    local target = clampedCurrent - (delta * step)
    state.scrollMaxOffset = maxValue
    if target < minValue then
        target = minValue
    elseif target > maxValue then
        target = maxValue
    end
    setScrollOffset(target)
end

getCurrentScrollOffset = function()
    if state.desiredScrollOffset ~= nil then
        return state.desiredScrollOffset
    end

    if state.scrollOffset ~= nil then
        return state.scrollOffset
    end

    local scrollbar = state.scrollbar
    if scrollbar and scrollbar.GetValue then
        local value = scrollbar:GetValue()
        if value ~= nil then
            return tonumber(value) or 0
        end
    end

    return 0
end

updateScrollContentAnchors = function()
    local scrollContainer = state.scrollContainer
    local scrollContent = state.scrollContent
    if not (scrollContainer and scrollContent) then
        return
    end

    scrollContent:ClearAnchors()
    local offsetY = -(state.scrollOffset or 0)
    scrollContent:SetAnchor(
        TOPLEFT,
        scrollContainer,
        TOPLEFT,
        state.scrollContentLeftOffset or 0,
        offsetY
    )
    scrollContent:SetAnchor(
        TOPRIGHT,
        scrollContainer,
        TOPRIGHT,
        state.scrollContentRightOffset or 0,
        offsetY
    )
end

measureTrackerContent = function(container, trackerModule, sectionId)
    if not container or (container.IsHidden and container:IsHidden()) then
        return 0, 0
    end

    local width = 0
    local height = 0
    local source
    local measuredFromTracker = false

    if trackerModule and trackerModule.GetContentSize then
        local ok, trackerWidth, trackerHeight = pcall(trackerModule.GetContentSize, trackerModule)
        if ok then
            width = tonumber(trackerWidth) or 0
            height = tonumber(trackerHeight) or 0
            source = "contentSize"
            measuredFromTracker = true
        end
    end

    if trackerModule and not (width > 0 and height > 0) and trackerModule.GetHeight then
        local ok, trackerHeight = pcall(trackerModule.GetHeight, trackerModule)
        if ok then
            height = tonumber(trackerHeight) or height or 0
            source = source or "heightOnly"
            measuredFromTracker = measuredFromTracker or source ~= nil
        end
    end

    if measuredFromTracker and width <= 0 then
        local holder = container and container.holder
        if holder and holder.GetWidth then
            width = math.max(width, holder:GetWidth() or 0)
        elseif container and container.GetWidth then
            width = math.max(width, container:GetWidth() or 0)
        end
    elseif not measuredFromTracker then
        local holder = container.holder
        if holder and holder.GetWidth then
            width = math.max(width, holder:GetWidth() or 0)
            height = math.max(height, holder:GetHeight() or 0)
        else
            width = math.max(width, container.GetWidth and container:GetWidth() or 0)
            height = math.max(height, container.GetHeight and container:GetHeight() or 0)
        end

        if not source then
            source = "container"
        end
    end

    if width < 0 then
        width = 0
    end
    if height < 0 then
        height = 0
    end

    if isDebugEnabled() then
        local containerHeight
        if container and type(container.GetHeight) == "function" then
            local ok, measured = pcall(container.GetHeight, container)
            if ok then
                containerHeight = measured
            end
        end

        debugLog(
            "TrackerHost: measureTrackerContent section=%s source=%s width=%s height=%s containerHeight=%s",
            tostring(sectionId or "<nil>"),
            tostring(source),
            tostring(width),
            tostring(height),
            tostring(containerHeight)
        )
    end

    return width, height
end

function TrackerHost.GetSectionOrder()
    local orderKeys
    local layout = Nvk3UT and Nvk3UT.TrackerHostLayout
    if layout and type(layout.GetSectionOrder) == "function" then
        local ok, order = pcall(layout.GetSectionOrder)
        if ok and type(order) == "table" then
            orderKeys = order
        end
    end

    if type(orderKeys) ~= "table" then
        orderKeys = normalizeSectionOrder(state.hostSettings and state.hostSettings.sectionOrder)
    end

    local orderIds = {}
    for index, key in ipairs(orderKeys) do
        orderIds[index] = SECTION_KEY_TO_ID[key] or key
    end

    return orderIds
end

function TrackerHost.ApplySectionOrderFromSettings(shouldRefresh)
    local layout = Nvk3UT and Nvk3UT.TrackerHostLayout
    if not (layout and type(layout.SetSectionOrder) == "function") then
        return nil
    end

    local hostSettings = ensureHostSettings()
    state.hostSettings = hostSettings

    local normalized = normalizeSectionOrder(hostSettings.sectionOrder)
    local applied = layout.SetSectionOrder(normalized)
    hostSettings.sectionOrder = type(applied) == "table" and applied or normalized

    if shouldRefresh ~= false then
        if performFullHostRefresh then
            performFullHostRefresh("sectionOrder")
        elseif anchorContainers then
            anchorContainers()
        end
    end

    return hostSettings.sectionOrder
end

function TrackerHost.GetSectionParent()
    return state.contentStack or state.scrollContent or state.root
end

function TrackerHost.GetSectionGap()
    return 0
end

function TrackerHost.GetSectionContainer(sectionId)
    if sectionId == "quest" then
        return state.questContainer
    elseif sectionId == "endeavor" then
        return state.endeavorContainer
    elseif sectionId == "achievement" then
        return state.achievementContainer
    elseif sectionId == "golden" then
        return state.goldenContainer
    end

    return nil
end

function TrackerHost.GetSectionTracker(sectionId)
    if sectionId == "quest" then
        return Nvk3UT and Nvk3UT.QuestTracker
    elseif sectionId == "endeavor" then
        return getEndeavorModule()
    elseif sectionId == "achievement" then
        return Nvk3UT and Nvk3UT.AchievementTracker
    elseif sectionId == "golden" then
        return Nvk3UT and Nvk3UT.GoldenTracker
    end

    return nil
end

function TrackerHost.GetSectionMeasurements(sectionId)
    local container = TrackerHost.GetSectionContainer(sectionId)
    local tracker = TrackerHost.GetSectionTracker(sectionId)
    return measureTrackerContent(container, tracker, sectionId)
end

function TrackerHost.GetLayoutSettings()
    state.layout = state.layout or ensureLayoutSettings()
    return state.layout
end

function TrackerHost.GetWindowBarSettings()
    state.windowBars = state.windowBars or ensureWindowBarSettings()
    return state.windowBars
end

function TrackerHost.GetHeaderControl()
    return state.headerBar
end

function TrackerHost.GetFooterControl()
    return state.footerBar
end

function TrackerHost.GetContentStack()
    return state.contentStack
end

function TrackerHost.GetScrollContent()
    return state.scrollContent
end

function TrackerHost.GetScrollContainer()
    return state.scrollContainer
end

function TrackerHost.GetScrollbar()
    return state.scrollbar
end

function TrackerHost.GetScrollbarSide()
    return getScrollbarSide()
end

function TrackerHost.GetScrollbarWidth()
    local scrollbar = state.scrollbar
    if scrollbar and scrollbar.GetWidth then
        local ok, width = pcall(scrollbar.GetWidth, scrollbar)
        if ok then
            width = tonumber(width)
            if width then
                return width
            end
        end
    end

    return SCROLLBAR_WIDTH
end

function TrackerHost.SetScrollbarHidden(hidden)
    local scrollbar = state.scrollbar
    if not (scrollbar and scrollbar.SetHidden) then
        return false
    end

    local current = scrollbar.IsHidden and scrollbar:IsHidden()
    if current == hidden then
        return false
    end

    scrollbar:SetHidden(hidden)
    return true
end

function TrackerHost.UpdateScrollbarRange(minValue, maxValue)
    minValue = tonumber(minValue) or 0
    maxValue = tonumber(maxValue) or 0

    local scrollbar = state.scrollbar
    state.scrollMaxOffset = math.max(0, maxValue)

    if not (scrollbar and scrollbar.SetMinMax) then
        return false
    end

    state.updatingScrollbar = true
    local ok, err = pcall(scrollbar.SetMinMax, scrollbar, minValue, maxValue)
    state.updatingScrollbar = false

    if not ok then
        debugLog("Failed to update scroll range", err)
        return false
    end

    return true
end

function TrackerHost.GetScrollOvershootPadding()
    return SCROLL_OVERSHOOT_PADDING
end

function TrackerHost.GetScrollContentRightOffset()
    return state.scrollContentRightOffset or 0
end

function TrackerHost.SetScrollContentRightOffset(offset)
    offset = tonumber(offset) or 0

    local current = state.scrollContentRightOffset or 0
    if not numbersDiffer(current, offset, 0.01) then
        return false
    end

    state.scrollContentRightOffset = offset
    applyViewportPadding()
    return true
end

function TrackerHost.SetScrollMaxOffset(maxOffset)
    state.scrollMaxOffset = math.max(0, tonumber(maxOffset) or 0)
end

function TrackerHost.GetScrollState()
    return {
        actual = state.scrollOffset or 0,
        desired = state.desiredScrollOffset,
        maxOffset = state.scrollMaxOffset or 0,
    }
end

function TrackerHost.SetScrollOffset(offset, skipScrollbarUpdate)
    return setScrollOffset(offset, skipScrollbarUpdate)
end

function TrackerHost.ReportSectionMissing(sectionId)
    if sectionId == "quest" then
        if not state.anchorWarnings.questMissing then
            debugLog("Quest container not ready for anchoring")
            state.anchorWarnings.questMissing = true
        end
    elseif sectionId == "endeavor" then
        if not state.anchorWarnings.endeavorMissing then
            debugLog("Endeavor container not ready for anchoring")
            state.anchorWarnings.endeavorMissing = true
        end
    elseif sectionId == "achievement" then
        if not state.anchorWarnings.achievementMissing then
            debugLog("Achievement container not ready for anchoring")
            state.anchorWarnings.achievementMissing = true
        end
    elseif sectionId == "golden" then
        if not state.anchorWarnings.goldenMissing then
            debugLog("Golden container not ready for anchoring")
            state.anchorWarnings.goldenMissing = true
        end
    end
end

function TrackerHost.ReportSectionAnchored(sectionId)
    if sectionId == "quest" then
        state.anchorWarnings.questMissing = false
    elseif sectionId == "endeavor" then
        state.anchorWarnings.endeavorMissing = false
    elseif sectionId == "achievement" then
        state.anchorWarnings.achievementMissing = false
    elseif sectionId == "golden" then
        state.anchorWarnings.goldenMissing = false
    end
end

local function measureContentSize()
    local totalHeight = 0
    local maxWidth = 0

    local layoutModule = Nvk3UT and Nvk3UT.TrackerHostLayout
    local headerTargetHeight = 0
    local footerTargetHeight = 0
    local headerHeight = 0
    local footerHeight = 0
    local headerVisible = false
    local footerVisible = false
    local topPadding = 0
    local bottomPadding = 0

    local sizes
    if layoutModule and type(layoutModule.UpdateHeaderFooterSizes) == "function" then
        sizes = layoutModule.UpdateHeaderFooterSizes(TrackerHost)
        headerTargetHeight = math.max(0, Num0(sizes.headerTargetHeight or sizes.headerHeight))
        footerTargetHeight = math.max(0, Num0(sizes.footerTargetHeight or sizes.footerHeight))
        headerHeight = math.max(0, Num0(sizes.headerHeight))
        if headerHeight <= 0 then
            headerHeight = headerTargetHeight
        end
        footerHeight = math.max(0, Num0(sizes.footerHeight))
        if footerHeight <= 0 then
            footerHeight = footerTargetHeight
        end
        headerVisible = sizes.headerVisible ~= false and headerTargetHeight > 0
        footerVisible = sizes.footerVisible ~= false and footerTargetHeight > 0
        topPadding = math.max(0, Num0(sizes.contentTopPadding))
        bottomPadding = math.max(0, Num0(sizes.contentBottomPadding))
    else
        headerHeight, footerHeight = getEffectiveBarHeights()
        headerTargetHeight = headerHeight
        footerTargetHeight = footerHeight
        headerVisible = headerTargetHeight > 0
        footerVisible = footerTargetHeight > 0

        local headerBar = state.headerBar
        if headerBar and headerBar.GetHeight then
            local measured = Num0(function()
                return headerBar:GetHeight()
            end)
            if measured > 0 then
                headerHeight = math.max(0, measured)
            end
        end
        if not headerVisible then
            headerHeight = 0
        end

        local footerBar = state.footerBar
        if footerBar and footerBar.GetHeight then
            local measured = Num0(function()
                return footerBar:GetHeight()
            end)
            if measured > 0 then
                footerHeight = math.max(0, measured)
            end
        end
        if not footerVisible then
            footerHeight = 0
        end
    end

    local headerWidth = 0
    local footerWidth = 0

    local headerBar = state.headerBar
    if headerBar and headerBar.GetWidth then
        if headerVisible then
            headerWidth = Num0(function()
                return headerBar:GetWidth()
            end)
        end
    end

    local footerBar = state.footerBar
    if footerBar and footerBar.GetWidth then
        if footerVisible then
            footerWidth = Num0(function()
                return footerBar:GetWidth()
            end)
        end
    end

    local questWidth, questHeight = measureTrackerContent(state.questContainer, Nvk3UT and Nvk3UT.QuestTracker, "quest")
    local endeavorWidth, endeavorHeight = measureTrackerContent(
        state.endeavorContainer,
        getEndeavorModule(),
        "endeavor"
    )
    local achievementWidth, achievementHeight = measureTrackerContent(
        state.achievementContainer,
        Nvk3UT and Nvk3UT.AchievementTracker,
        "achievement"
    )
    local goldenWidth, goldenHeight = measureTrackerContent(
        state.goldenContainer,
        Nvk3UT and Nvk3UT.GoldenTracker,
        "golden"
    )

    questWidth = Num0(questWidth)
    questHeight = math.max(0, Num0(questHeight))
    endeavorWidth = Num0(endeavorWidth)
    endeavorHeight = math.max(0, Num0(endeavorHeight))
    achievementWidth = Num0(achievementWidth)
    achievementHeight = math.max(0, Num0(achievementHeight))
    goldenWidth = Num0(goldenWidth)
    goldenHeight = math.max(0, Num0(goldenHeight))

    local questVisible = questHeight > 0
    local endeavorVisible = endeavorHeight > 0
    local achievementVisible = achievementHeight > 0
    local goldenVisible = goldenHeight > 0
    local gap = 0

    if questVisible then
        totalHeight = totalHeight + questHeight
    end

    if endeavorVisible then
        if questVisible then
            totalHeight = totalHeight + gap
        end
        totalHeight = totalHeight + endeavorHeight
    end

    if achievementVisible then
        if questVisible or endeavorVisible then
            totalHeight = totalHeight + gap
        end
        totalHeight = totalHeight + achievementHeight
    end

    if goldenVisible then
        if questVisible or endeavorVisible or achievementVisible then
            totalHeight = totalHeight + gap
        end
        totalHeight = totalHeight + goldenHeight
    end

    totalHeight = totalHeight + math.max(0, topPadding) + math.max(0, bottomPadding)
    totalHeight = totalHeight + math.max(0, headerHeight) + math.max(0, footerHeight)

    maxWidth = math.max(
        maxWidth,
        headerWidth,
        footerWidth,
        questWidth,
        endeavorWidth,
        achievementWidth,
        goldenWidth
    )

    if isDebugEnabled() then
        debugLog(
            "TrackerHost: measureContentSize questHeight=%s totalHeight=%s",
            tostring(questHeight),
            tostring(totalHeight)
        )
    end

    return maxWidth, totalHeight
end

local function applyLayoutConstraints()
    if not (state.root and state.root.SetDimensionConstraints) then
        return
    end

    local layout = state.layout or ensureLayoutSettings()
    state.layout = layout

    local minWidth = layout.minWidth or MIN_WIDTH
    local minHeight = layout.minHeight or MIN_HEIGHT
    local maxWidth = layout.maxWidth
    local maxHeight = layout.maxHeight

    if maxWidth and maxHeight then
        state.root:SetDimensionConstraints(minWidth, minHeight, maxWidth, maxHeight)
    else
        state.root:SetDimensionConstraints(minWidth, minHeight)
    end
end

local function updateWindowGeometry()
    if not (state.root and state.window) then
        return
    end

    state.layout = ensureLayoutSettings()
    local layout = state.layout
    local appearance = state.appearance or ensureAppearanceSettings()
    state.appearance = appearance

    local padding = math.max(0, tonumber(appearance and appearance.padding) or 0)
    local contentWidth, contentHeight = measureContentSize()

    local minWidth = layout.minWidth or MIN_WIDTH
    local minHeight = layout.minHeight or MIN_HEIGHT
    local maxWidth = layout.maxWidth or minWidth
    local maxHeight = layout.maxHeight or minHeight

    local targetWidth = tonumber(state.window.width) or DEFAULT_WINDOW.width
    local targetHeight = tonumber(state.window.height) or DEFAULT_WINDOW.height

    local collapsed = state.collapsed == true
    targetWidth = clamp(targetWidth, minWidth, maxWidth)
    targetHeight = clamp(targetHeight, minHeight, maxHeight)

    if not collapsed and layout.autoGrowH then
        local desiredWidth = math.floor((contentWidth + (padding * 2)) + 0.5)
        targetWidth = clamp(desiredWidth, minWidth, maxWidth)
    end

    if not collapsed and layout.autoGrowV then
        local desiredHeight = math.floor((contentHeight + (padding * 2)) + 0.5)
        targetHeight = clamp(desiredHeight, minHeight, maxHeight)
    end

    state.window.width = targetWidth
    state.window.height = targetHeight

    applyLayoutConstraints()

    clampWindowToScreen(targetWidth, targetHeight)

    local anchorParent = GuiRoot or state.root:GetParent()
    state.root:ClearAnchors()
    state.root:SetAnchor(TOPLEFT, anchorParent, TOPLEFT, state.window.left or 0, state.window.top or 0)
    state.root:SetDimensions(targetWidth, targetHeight)
    state.root:SetClampedToScreen(state.window.clamp ~= false)
end

local function updateCornerButtonAnchor()
    local button = state.cornerButton
    if not (button and state.root) then
        return
    end

    local position = getCornerPosition()
    local anchor = CORNER_ANCHORS[position] or CORNER_ANCHORS[DEFAULT_CORNER_POSITION]
    if not anchor then
        return
    end

    button:ClearAnchors()
    button:SetAnchor(anchor.point, state.root, anchor.relative, anchor.offsetX, anchor.offsetY)
end

updateCornerButtonVisualState = function()
    local texture = state.cornerTexture
    if not texture then
        return
    end

    local texturePath = CORNER_TEXTURES.normal
    if state.cornerPressed and CORNER_TEXTURES.pressed then
        texturePath = CORNER_TEXTURES.pressed
    elseif state.cornerHover and CORNER_TEXTURES.hover then
        texturePath = CORNER_TEXTURES.hover
    end

    texture:SetTexture(texturePath)

    local rotation = CORNER_ROTATIONS[getCornerPosition()] or CORNER_ROTATIONS[DEFAULT_CORNER_POSITION]
    if state.collapsed then
        rotation = rotation + math.pi
    end

    if texture.SetTextureRotation then
        texture:SetTextureRotation(rotation, 0.5, 0.5)
    end
end

applyCollapsedVisibility = function()
    local collapsed = state.collapsed == true

    if state.backdrop then
        local appearance = state.appearance or ensureAppearanceSettings()
        local backgroundEnabled = appearance.enabled ~= false
        local edgeAlpha = clamp(appearance.edgeAlpha, 0, 1)
        local borderEnabled = appearance.edgeEnabled ~= false and edgeAlpha > 0
        local shouldShow = backgroundEnabled or borderEnabled

        state.backdrop:SetHidden(collapsed or not shouldShow)
    end

    if state.scrollContainer then
        state.scrollContainer:SetHidden(collapsed)
    end

    if state.scrollbar then
        if collapsed then
            state.scrollbar:SetHidden(true)
        else
            local shouldHide = (state.scrollMaxOffset or 0) <= 0
            state.scrollbar:SetHidden(shouldHide)
        end
    end

    if state.headerBar and state.headerBar.SetHidden then
        if collapsed then
            state.headerBar:SetHidden(true)
        end
    end

    if state.footerBar and state.footerBar.SetHidden then
        if collapsed then
            state.footerBar:SetHidden(true)
        end
    end

    if state.dragLayer and state.dragLayer.SetHidden then
        state.dragLayer:SetHidden(collapsed)
    end

    if collapsed and state.resizeGrips then
        for _, grip in pairs(state.resizeGrips) do
            if grip then
                if grip.SetMouseEnabled then
                    grip:SetMouseEnabled(false)
                end
                if grip.SetHidden then
                    grip:SetHidden(true)
                end
            end
        end
    end
end

setCollapsed = function(collapsed)
    local normalized = collapsed == true
    -- CornerButtonEnabled only controls the visibility of the corner button,
    -- not whether collapsing is allowed (used by keybinds as well).

    if not state.root then
        state.collapsed = normalized
        return state.collapsed
    end

    if state.collapsed == normalized then
        updateCornerButtonVisualState()
        return state.collapsed
    end

    state.collapsed = normalized

    if state.root and state.root.SetResizeHandleSize then
        if normalized then
            state.root:SetResizeHandleSize(0)
        else
            state.root:SetResizeHandleSize(state.window and state.window.locked == true and 0 or RESIZE_HANDLE_SIZE)
        end
    end

    applyLayoutConstraints()
    updateWindowGeometry()

    if normalized then
        applyCollapsedVisibility()
    else
        applyWindowBars()
        applyCollapsedVisibility()
        refreshScroll()
        applyWindowLock()

        if not state.cornerExpandFullRefreshPending
            and type(zo_callLater) == "function"
            and type(performFullHostRefresh) == "function"
            and state.root then
            state.cornerExpandFullRefreshPending = true
            zo_callLater(function()
                state.cornerExpandFullRefreshPending = false

                if state.root and type(performFullHostRefresh) == "function" then
                    performFullHostRefresh("cornerExpand")
                end
            end, 1)
        end
    end

    refreshCornerButton()

    return state.collapsed
end

refreshCornerButton = function()
    local button = state.cornerButton
    if not button then
        return
    end

    local enabled = isCornerButtonEnabled()
    if not enabled then
        button:SetHidden(true)
        -- Do not force un-collapse; collapsing is still allowed via keybind.
        return
    end

    button:SetHidden(false)
    updateCornerButtonAnchor()
    updateCornerButtonVisualState()
end

ensureCornerButton = function()
    if not (state.root and WINDOW_MANAGER) then
        return
    end

    local enabled = isCornerButtonEnabled()
    local button = state.cornerButton

    if not enabled then
        if button then
            button:SetHidden(true)
        end
        return
    end

    if not button then
        button = WINDOW_MANAGER:CreateControl(nil, state.root, CT_BUTTON)
        if not button then
            return
        end

        button:SetDimensions(CORNER_BUTTON_SIZE, CORNER_BUTTON_SIZE)
        button:SetMouseEnabled(true)
        if button.SetDrawLayer then
            button:SetDrawLayer(DL_OVERLAY)
            button:SetDrawTier(DT_MEDIUM)
            button:SetDrawLevel(2)
        end
        button:SetHandler("OnMouseEnter", function()
            state.cornerHover = true
            updateCornerButtonVisualState()
        end)
        button:SetHandler("OnMouseExit", function()
            state.cornerHover = false
            state.cornerPressed = false
            updateCornerButtonVisualState()
        end)
        button:SetHandler("OnMouseDown", function(_, mouseButton)
            if mouseButton ~= LEFT_MOUSE_BUTTON then
                return
            end

            state.cornerPressed = true
            updateCornerButtonVisualState()
        end)
        button:SetHandler("OnMouseUp", function(_, mouseButton)
            if mouseButton ~= LEFT_MOUSE_BUTTON then
                return
            end

            state.cornerPressed = false
            updateCornerButtonVisualState()
            setCollapsed(not state.collapsed)
        end)

        local texture = WINDOW_MANAGER:CreateControl(nil, button, CT_TEXTURE)
        if texture then
            texture:SetAnchorFill()
            texture:SetTexture(CORNER_TEXTURES.normal)
            texture:SetColor(1, 1, 1, 0.9)
            if texture.SetDrawLayer then
                texture:SetDrawLayer(DL_OVERLAY)
                texture:SetDrawTier(DT_MEDIUM)
                texture:SetDrawLevel(3)
            end
            texture:SetHidden(false)
            state.cornerTexture = texture
        end

        state.cornerButton = button
    end

    refreshCornerButton()
end

local function applyFeatureSettings()
    state.features = ensureFeatureSettings()
    local features = state.features

    local hideBase = false
    local sv = getSavedVars()
    local general = sv and sv.General
    if general and general.hideBaseQuestTracker ~= nil then
        hideBase = general.hideBaseQuestTracker == true
    elseif features and features.hideDefaultQuestTracker ~= nil then
        hideBase = features.hideDefaultQuestTracker == true
    end

    if Nvk3UT and Nvk3UT.QuestTracker and type(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility) == "function" then
        pcall(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility)
    elseif Nvk3UT and type(Nvk3UT.ApplyBaseQuestTrackerVisibility) == "function" then
        pcall(Nvk3UT.ApplyBaseQuestTrackerVisibility)
    elseif ZO_QuestTracker and ZO_QuestTracker.SetHidden then
        if state.previousDefaultQuestTrackerHidden == nil then
            state.previousDefaultQuestTrackerHidden = ZO_QuestTracker:IsHidden()
        end

        if hideBase then
            ZO_QuestTracker:SetHidden(true)
        else
            if state.previousDefaultQuestTrackerHidden ~= nil then
                ZO_QuestTracker:SetHidden(state.previousDefaultQuestTrackerHidden)
            else
                ZO_QuestTracker:SetHidden(false)
            end
        end
    end
end

local function anchorContainers()
    local scrollContent = state.scrollContent or state.root
    local headerBar = state.headerBar
    local contentStack = state.contentStack
    local footerBar = state.footerBar

    if not scrollContent then
        return
    end

    local layoutModule = Nvk3UT and Nvk3UT.TrackerHostLayout
    local headerHeight = 0
    local headerVisible = false
    if layoutModule and type(layoutModule.UpdateHeaderFooterSizes) == "function" then
        local sizes = layoutModule.UpdateHeaderFooterSizes(TrackerHost)
        headerHeight = math.max(0, tonumber(sizes.headerHeight) or 0)
        local targetHeight = math.max(0, tonumber(sizes.headerTargetHeight or sizes.headerHeight) or 0)
        headerVisible = headerBar ~= nil and sizes.headerVisible ~= false and targetHeight > 0
    else
        headerHeight = getEffectiveBarHeights()
        headerVisible = headerBar ~= nil and headerHeight > 0.5
    end

    if headerBar then
        headerBar:ClearAnchors()
        headerBar:SetAnchor(TOPLEFT, scrollContent, TOPLEFT, 0, 0)
        headerBar:SetAnchor(TOPRIGHT, scrollContent, TOPRIGHT, 0, 0)
    end

    if contentStack then
        contentStack:ClearAnchors()
        if headerVisible and headerBar then
            contentStack:SetAnchor(TOPLEFT, headerBar, BOTTOMLEFT, 0, 0)
            contentStack:SetAnchor(TOPRIGHT, headerBar, BOTTOMRIGHT, 0, 0)
        else
            contentStack:SetAnchor(TOPLEFT, scrollContent, TOPLEFT, 0, 0)
            contentStack:SetAnchor(TOPRIGHT, scrollContent, TOPRIGHT, 0, 0)
        end
    end

    if footerBar then
        footerBar:ClearAnchors()
        if contentStack then
            footerBar:SetAnchor(TOPLEFT, contentStack, BOTTOMLEFT, 0, 0)
            footerBar:SetAnchor(TOPRIGHT, contentStack, BOTTOMRIGHT, 0, 0)
        elseif headerVisible and headerBar then
            footerBar:SetAnchor(TOPLEFT, headerBar, BOTTOMLEFT, 0, 0)
            footerBar:SetAnchor(TOPRIGHT, headerBar, BOTTOMRIGHT, 0, 0)
        else
            footerBar:SetAnchor(TOPLEFT, scrollContent, TOPLEFT, 0, 0)
            footerBar:SetAnchor(TOPRIGHT, scrollContent, TOPRIGHT, 0, 0)
        end
    end

    local parent = contentStack or scrollContent
    if not parent then
        return
    end

    layoutModule = layoutModule or (Nvk3UT and Nvk3UT.TrackerHostLayout)
    if layoutModule and type(layoutModule.ApplyLayout) == "function" then
        layoutModule.ApplyLayout(TrackerHost)
        return
    end
end

applyWindowBars = function()
    state.windowBars = ensureWindowBarSettings()

    if not state.root then
        return
    end

    local layoutModule = Nvk3UT and Nvk3UT.TrackerHostLayout
    local headerHeight, footerHeight = getEffectiveBarHeights()
    local headerVisible = headerHeight > 0
    local footerVisible = footerHeight > 0
    if layoutModule and type(layoutModule.UpdateHeaderFooterSizes) == "function" then
        local sizes = layoutModule.UpdateHeaderFooterSizes(TrackerHost)
        headerHeight = math.max(0, tonumber(sizes.headerTargetHeight or sizes.headerHeight) or 0)
        footerHeight = math.max(0, tonumber(sizes.footerTargetHeight or sizes.footerHeight) or 0)
        headerVisible = sizes.headerVisible ~= false and headerHeight > 0
        footerVisible = sizes.footerVisible ~= false and footerHeight > 0
    end

    local headerBar = state.headerBar
    if headerBar then
        if headerBar.SetHeight then
            local currentHeight = headerBar.GetHeight and headerBar:GetHeight() or headerHeight
            if numbersDiffer(currentHeight, headerHeight) then
                headerBar:SetHeight(headerHeight)
            end
        end
        if headerBar.SetHidden then
            local shouldHide = not headerVisible
            local currentHidden = headerBar.IsHidden and headerBar:IsHidden()
            if currentHidden ~= shouldHide then
                headerBar:SetHidden(shouldHide)
            end
        end
        headerBar:SetMouseEnabled(headerVisible)
    end

    local footerBar = state.footerBar
    if footerBar then
        if footerBar.SetHeight then
            local currentHeight = footerBar.GetHeight and footerBar:GetHeight() or footerHeight
            if numbersDiffer(currentHeight, footerHeight) then
                footerBar:SetHeight(footerHeight)
            end
        end
        if footerBar.SetHidden then
            local shouldHide = not footerVisible
            local currentHidden = footerBar.IsHidden and footerBar:IsHidden()
            if currentHidden ~= shouldHide then
                footerBar:SetHidden(shouldHide)
            end
        end
        footerBar:SetMouseEnabled(footerVisible)
    end

    anchorContainers()
end

applyScrollbarSide = function(showScrollbar)
    local scrollbar = state.scrollbar
    local parent = state.scrollContainer or state.clientArea or state.root
    local scrollbarWidth = Num0(scrollbar and scrollbar.GetWidth and scrollbar:GetWidth())
    if scrollbarWidth <= 0 then
        scrollbarWidth = SCROLLBAR_WIDTH
    end

    if showScrollbar == nil then
        if scrollbar and scrollbar.IsHidden then
            showScrollbar = not scrollbar:IsHidden()
        else
            showScrollbar = (state.scrollMaxOffset or 0) > 0.5
        end
    end

    local desiredLeftOffset = 0
    local desiredRightOffset = 0
    if showScrollbar then
        if getScrollbarSide() == "left" then
            desiredLeftOffset = scrollbarWidth
            desiredRightOffset = -RESIZE_BORDER_THICKNESS
        else
            desiredRightOffset = -scrollbarWidth
        end
    end

    state.scrollContentLeftOffset = desiredLeftOffset
    state.scrollContentRightOffset = desiredRightOffset

    if scrollbar and parent then
        scrollbar:ClearAnchors()
        if getScrollbarSide() == "left" then
            scrollbar:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
            scrollbar:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 0, 0)
        else
            scrollbar:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
            scrollbar:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
        end
        if scrollbar.SetWidth then
            scrollbar:SetWidth(SCROLLBAR_WIDTH)
        end
    end

    updateScrollContentAnchors()
end

local function getViewportInsets()
    local appearance = state.appearance or ensureAppearanceSettings()
    local padding = math.max(0, tonumber(appearance and appearance.padding) or 0)
    local leftInset = padding
    local rightInset = padding
    local fixApplied = false

    if getScrollbarSide() == "left" then
        rightInset = rightInset + SCROLLBAR_SIDE_INSET_FIX
        fixApplied = true
    end

    return leftInset, rightInset, fixApplied
end

applyViewportPadding = function()
    if not state.root then
        return
    end

    local leftInset, rightInset = getViewportInsets()
    local appearance = state.appearance or ensureAppearanceSettings()
    local padding = math.max(0, tonumber(appearance and appearance.padding) or 0)

    local containerParent = state.clientArea or state.root

    if state.scrollContainer and containerParent then
        state.scrollContainer:ClearAnchors()
        state.scrollContainer:SetAnchor(TOPLEFT, containerParent, TOPLEFT, leftInset, padding)
        state.scrollContainer:SetAnchor(BOTTOMRIGHT, containerParent, BOTTOMRIGHT, -rightInset, -padding)
    end

    applyScrollbarSide()
end

function TrackerHost.GetContentAlignment()
    return getContentAlign()
end

function TrackerHost.GetViewportInsets()
    local leftInset, rightInset = getViewportInsets()
    return leftInset, rightInset
end

function TrackerHost.GetViewportWidth()
    local container = state.scrollContainer or state.clientArea or state.root
    if not (container and container.GetWidth) then
        return nil
    end

    local ok, width = pcall(container.GetWidth, container)
    if not ok then
        return nil
    end

    local resolved = tonumber(width) or 0
    if resolved <= 0 then
        return 0
    end

    if container ~= state.scrollContainer then
        local leftInset, rightInset = getViewportInsets()
        resolved = resolved - leftInset - rightInset
        if resolved < 0 then
            resolved = 0
        end
    end

    return resolved
end

function TrackerHost.ApplyChevronVisualTopRightExpanded(chevron)
    if not chevron then
        return nil, nil
    end

    local texturePath = CORNER_TEXTURES.normal
    if chevron.SetTexture then
        chevron:SetTexture(texturePath)
    end

    local rotation = CORNER_ROTATIONS.TOP_RIGHT or 0
    if chevron.SetTextureRotation then
        chevron:SetTextureRotation(rotation, 0.5, 0.5)
    end

    if isDebugEnabled() and not loggedTopRightChevronVisual then
        debugLog(
            "Corner TOP_RIGHT expanded visual: texture=%s rotation=%s",
            tostring(texturePath),
            tostring(rotation)
        )
        loggedTopRightChevronVisual = true
    end

    return texturePath, rotation
end

function TrackerHost.ApplyViewportInsets()
    applyViewportPadding()
end

refreshScroll = function(targetOffset)
    local scrollContainer = state.scrollContainer
    local scrollContent = state.scrollContent
    local scrollbar = state.scrollbar

    if not (scrollContainer and scrollContent and scrollbar) then
        return
    end

    if state.collapsed then
        scrollbar:SetHidden(true)
        return
    end

    local previousActual = state.scrollOffset
    if previousActual == nil then
        local getValue = scrollbar.GetValue
        if getValue then
            previousActual = getValue(scrollbar) or 0
        else
            previousActual = 0
        end
    end

    local previousDesired = targetOffset
    if previousDesired == nil then
        previousDesired = state.desiredScrollOffset or previousActual or 0
    end

    local _, questHeight = measureTrackerContent(state.questContainer, Nvk3UT and Nvk3UT.QuestTracker, "quest")
    local _, endeavorHeight = measureTrackerContent(
        state.endeavorContainer,
        getEndeavorModule(),
        "endeavor"
    )
    local _, achievementHeight = measureTrackerContent(
        state.achievementContainer,
        Nvk3UT and Nvk3UT.AchievementTracker,
        "achievement"
    )
    local _, goldenHeight = measureTrackerContent(
        state.goldenContainer,
        Nvk3UT and Nvk3UT.GoldenTracker,
        "golden"
    )

    questHeight = math.max(0, Num0(questHeight))
    endeavorHeight = math.max(0, Num0(endeavorHeight))
    achievementHeight = math.max(0, Num0(achievementHeight))
    goldenHeight = math.max(0, Num0(goldenHeight))

    local gap = 0

    local questVisible = questHeight > 0
    local endeavorVisible = endeavorHeight > 0
    local achievementVisible = achievementHeight > 0
    local goldenVisible = goldenHeight > 0

    if state.questContainer and state.questContainer.SetHeight then
        state.questContainer:SetHeight(questHeight)
    end

    if state.endeavorContainer and state.endeavorContainer.SetHeight then
        state.endeavorContainer:SetHeight(endeavorHeight)
    end

    if state.achievementContainer and state.achievementContainer.SetHeight then
        state.achievementContainer:SetHeight(achievementHeight)
    end

    if state.goldenContainer and state.goldenContainer.SetHeight then
        state.goldenContainer:SetHeight(goldenHeight)
    end

    local layoutModule = Nvk3UT and Nvk3UT.TrackerHostLayout
    local canUseLayoutModule = layoutModule
        and type(layoutModule.UpdateHeaderFooterSizes) == "function"
        and type(layoutModule.UpdateScrollAreaHeight) == "function"
        and type(layoutModule.ApplyLayout) == "function"

    local totalContentHeight = questHeight + endeavorHeight + achievementHeight + goldenHeight
    local debugHeaderHeight = 0
    local debugFooterHeight = 0

    if canUseLayoutModule then
        local sizes = layoutModule.UpdateHeaderFooterSizes(TrackerHost)

        local topPadding = math.max(0, Num0(sizes and sizes.contentTopPadding))
        local bottomPadding = math.max(0, Num0(sizes and sizes.contentBottomPadding))

        local contentStackHeight = topPadding
        if questVisible then
            contentStackHeight = contentStackHeight + questHeight
        end
        if endeavorVisible then
            if questVisible then
                contentStackHeight = contentStackHeight + gap
            end
            contentStackHeight = contentStackHeight + endeavorHeight
        end
        if achievementVisible then
            if questVisible or endeavorVisible then
                contentStackHeight = contentStackHeight + gap
            end
            contentStackHeight = contentStackHeight + achievementHeight
        end
        if goldenVisible then
            if questVisible or endeavorVisible or achievementVisible then
                contentStackHeight = contentStackHeight + gap
            end
            contentStackHeight = contentStackHeight + goldenHeight
        end
        contentStackHeight = contentStackHeight + bottomPadding
        contentStackHeight = math.max(0, contentStackHeight)

        local contentStack = state.contentStack
        if contentStack and contentStack.SetHeight then
            contentStack:SetHeight(contentStackHeight)
        end

        local headerHeight = math.max(0, Num0(sizes and (sizes.headerHeight or sizes.headerTargetHeight)))
        local footerHeight = math.max(0, Num0(sizes and (sizes.footerHeight or sizes.footerTargetHeight)))
        totalContentHeight = headerHeight + contentStackHeight + footerHeight
        debugHeaderHeight = headerHeight
        debugFooterHeight = footerHeight

        layoutModule.ApplyLayout(TrackerHost, sizes)
    else
        local headerBar = state.headerBar
        local footerBar = state.footerBar
        local bars = state.windowBars or ensureWindowBarSettings()

        local headerTargetHeight = math.max(0, Num0(bars and bars.headerHeightPx))
        local footerTargetHeight = math.max(0, Num0(bars and bars.footerHeightPx))
        local headerVisible = headerTargetHeight > 0
        local footerVisible = footerTargetHeight > 0
        local headerHeight = headerTargetHeight
        local footerHeight = footerTargetHeight

        if headerBar and headerBar.GetHeight then
            local measured = Num0(function()
                return headerBar:GetHeight()
            end)
            if measured > 0 then
                headerHeight = math.max(0, measured)
            end
        end
        if footerBar and footerBar.GetHeight then
            local measured = Num0(function()
                return footerBar:GetHeight()
            end)
            if measured > 0 then
                footerHeight = math.max(0, measured)
            end
        end

        if headerBar then
            if headerBar.SetHeight then
                local currentHeight = headerBar.GetHeight and headerBar:GetHeight() or headerTargetHeight
                if numbersDiffer(currentHeight, headerTargetHeight) then
                    headerBar:SetHeight(headerTargetHeight)
                end
            end
            if headerBar.SetHidden then
                local shouldHide = not headerVisible
                local currentHidden = headerBar.IsHidden and headerBar:IsHidden()
                if currentHidden ~= shouldHide then
                    headerBar:SetHidden(shouldHide)
                end
            end
            headerBar:SetMouseEnabled(headerVisible)
        end

        if footerBar then
            if footerBar.SetHeight then
                local currentHeight = footerBar.GetHeight and footerBar:GetHeight() or footerTargetHeight
                if numbersDiffer(currentHeight, footerTargetHeight) then
                    footerBar:SetHeight(footerTargetHeight)
                end
            end
            if footerBar.SetHidden then
                local shouldHide = not footerVisible
                local currentHidden = footerBar.IsHidden and footerBar:IsHidden()
                if currentHidden ~= shouldHide then
                    footerBar:SetHidden(shouldHide)
                end
            end
            footerBar:SetMouseEnabled(footerVisible)
        end

        if not headerVisible then
            headerHeight = 0
        else
            headerHeight = headerTargetHeight
        end

        if not footerVisible then
            footerHeight = 0
        else
            footerHeight = footerTargetHeight
        end

        local topPadding = 0
        local bottomPadding = 0

        local contentStackHeight = topPadding
        if questVisible then
            contentStackHeight = contentStackHeight + questHeight
        end
        if endeavorVisible then
            if questVisible then
                contentStackHeight = contentStackHeight + gap
            end
            contentStackHeight = contentStackHeight + endeavorHeight
        end
        if achievementVisible then
            if questVisible or endeavorVisible then
                contentStackHeight = contentStackHeight + gap
            end
            contentStackHeight = contentStackHeight + achievementHeight
        end
        if goldenVisible then
            if questVisible or endeavorVisible or achievementVisible then
                contentStackHeight = contentStackHeight + gap
            end
            contentStackHeight = contentStackHeight + goldenHeight
        end
        contentStackHeight = contentStackHeight + bottomPadding
        contentStackHeight = math.max(0, contentStackHeight)

        if state.contentStack and state.contentStack.SetHeight then
            state.contentStack:SetHeight(contentStackHeight)
        end

        local contentHeight = headerHeight + contentStackHeight + footerHeight
        contentHeight = math.max(0, contentHeight)
        totalContentHeight = contentHeight
        debugHeaderHeight = headerHeight
        debugFooterHeight = footerHeight

        if scrollContent.SetResizeToFitDescendents then
            scrollContent:SetResizeToFitDescendents(false)
        end
        if scrollContent.SetHeight then
            scrollContent:SetHeight(contentHeight)
        end

        local viewportHeight = Num0(scrollContainer and scrollContainer.GetHeight and scrollContainer:GetHeight())
        local overshootPadding = 0
        if viewportHeight > 0 and contentHeight > viewportHeight then
            overshootPadding = SCROLL_OVERSHOOT_PADDING
        end

        local maxOffset = math.max(contentHeight - viewportHeight + overshootPadding, 0)
        local showScrollbar = maxOffset > 0.5

        if scrollbar.SetMinMax then
            state.updatingScrollbar = true
            local ok, err = pcall(scrollbar.SetMinMax, scrollbar, 0, maxOffset)
            state.updatingScrollbar = false
            if not ok then
                debugLog("Failed to update scroll range", err)
            end
        end

        if scrollbar.SetHidden then
            scrollbar:SetHidden(not showScrollbar)
        end

        state.scrollMaxOffset = maxOffset
        applyScrollbarSide(showScrollbar)
    end

    debugLog(string.format(
        "Heights q=%s e=%s a=%s g=%s total=%s (header=%s footer=%s gap=%s)",
        tostring(questHeight),
        tostring(endeavorHeight),
        tostring(achievementHeight),
        tostring(goldenHeight),
        tostring(totalContentHeight),
        tostring(debugHeaderHeight),
        tostring(debugFooterHeight),
        tostring(gap)
    ))

    local debugViewportHeight = nil
    local scrollContainerForDebug = state.scrollContainer
    if scrollContainerForDebug and scrollContainerForDebug.GetHeight then
        local ok, h = pcall(scrollContainerForDebug.GetHeight, scrollContainerForDebug)
        if ok and type(h) == "number" then
            debugViewportHeight = h
        end
    end

    local debugScrollRange = state.scrollMaxOffset

    debugLog(string.format(
        "Scroll viewport=%s content=%s range=%s",
        tostring(debugViewportHeight),
        tostring(totalContentHeight),
        tostring(debugScrollRange)
    ))

    local desiredOffset = math.max(0, previousDesired or 0)
    setScrollOffset(desiredOffset)
end

local function createDragLayer()
    if state.dragLayer or not (state.root and WINDOW_MANAGER) then
        return
    end

    local dragLayer = WINDOW_MANAGER:CreateControl(nil, state.root, CT_CONTROL)
    if not dragLayer then
        return
    end

    dragLayer:SetAnchorFill()
    dragLayer:SetDrawLayer(DL_BACKGROUND)
    dragLayer:SetDrawTier(DT_LOW)
    dragLayer:SetDrawLevel(1)
    dragLayer:SetMouseEnabled(false)
    if dragLayer.SetExcludeFromResizeToFitExtents then
        dragLayer:SetExcludeFromResizeToFitExtents(true)
    end

    state.dragLayer = dragLayer
end

local function createScrollContainer()
    if state.scrollContainer or not (state.root and WINDOW_MANAGER) then
        return
    end

    local parent = state.clientArea or state.root

    local createdFromTemplate = false
    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(
        SCROLL_CONTAINER_NAME,
        parent,
        "ZO_ScrollContainer"
    )
    if scrollContainer then
        createdFromTemplate = true
    else
        scrollContainer = WINDOW_MANAGER:CreateControl(SCROLL_CONTAINER_NAME, parent, CT_SCROLL)
    end
    if not scrollContainer then
        return
    end

    if createdFromTemplate and type(ZO_Scroll_Initialize) == "function" then
        ZO_Scroll_Initialize(scrollContainer)
    end

    scrollContainer:SetMouseEnabled(false)
    scrollContainer:SetClampedToScreen(false)
    scrollContainer:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    scrollContainer:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
    if scrollContainer.SetBackgroundColor then
        scrollContainer:SetBackgroundColor(0, 0, 0, 0)
    end

    local scrollBackground = WINDOW_MANAGER:CreateControl(SCROLL_BACKGROUND_NAME, scrollContainer, CT_CONTROL)
    if scrollBackground then
        scrollBackground:SetAnchorFill()
        scrollBackground:SetMouseEnabled(true)
        scrollBackground:SetDrawLayer(DL_BACKGROUND)
        scrollBackground:SetDrawTier(DT_LOW)
        scrollBackground:SetDrawLevel(0)
        if scrollBackground.SetAlpha then
            scrollBackground:SetAlpha(0)
        end
        if scrollBackground.SetExcludeFromResizeToFitExtents then
            scrollBackground:SetExcludeFromResizeToFitExtents(true)
        end
        scrollBackground:SetHandler("OnMouseWheel", function(_, delta)
            adjustScroll(delta)
        end)

        state.scrollBackground = scrollBackground
    end

    local scrollContent = scrollContainer:GetNamedChild("ScrollChild")
    if scrollContent then
        if scrollContent.SetName then
            scrollContent:SetName(SCROLL_CONTENT_NAME)
        end
    else
        scrollContent = WINDOW_MANAGER:CreateControl(SCROLL_CONTENT_NAME, scrollContainer, CT_CONTROL)
        if scrollContainer.SetScrollChild then
            scrollContainer:SetScrollChild(scrollContent)
        end
    end

    scrollContent:SetMouseEnabled(false)
    scrollContent:ClearAnchors()
    scrollContent:SetAnchor(TOPLEFT, scrollContainer, TOPLEFT, 0, 0)
    scrollContent:SetAnchor(TOPRIGHT, scrollContainer, TOPRIGHT, 0, 0)
    if scrollContent.SetResizeToFitDescendents then
        scrollContent:SetResizeToFitDescendents(false)
    end

    local scrollbar = scrollContainer:GetNamedChild("ScrollBar")
    if scrollbar then
        if scrollbar.SetName then
            scrollbar:SetName(SCROLLBAR_NAME)
        end
    elseif not createdFromTemplate then
        scrollbar = WINDOW_MANAGER:CreateControl(SCROLLBAR_NAME, scrollContainer, CT_SCROLLBAR)
    end

    if scrollbar then
        scrollbar:SetMouseEnabled(true)
        if not createdFromTemplate then
            scrollbar:ClearAnchors()
            scrollbar:SetAnchor(TOPRIGHT, scrollContainer, TOPRIGHT, 0, 0)
            scrollbar:SetAnchor(BOTTOMRIGHT, scrollContainer, BOTTOMRIGHT, 0, 0)
            if scrollbar.SetWidth then
                scrollbar:SetWidth(SCROLLBAR_WIDTH)
            end
        end
        if createdFromTemplate and not scrollbar.GetName then
            debugLog("TrackerHost: Scrollbar from template is missing expected API")
        end
        if scrollbar.SetHidden then
            scrollbar:SetHidden(true)
        end
        if scrollbar.SetAllowDragging then
            scrollbar:SetAllowDragging(true)
        end
        if scrollbar.SetStep then
            scrollbar:SetStep(32)
        end
        if scrollbar.SetValue then
            scrollbar:SetValue(0)
        end
        if scrollbar.SetMinMax then
            scrollbar:SetMinMax(0, 0)
        end

        scrollbar:SetHandler("OnValueChanged", function(_, value)
            if state.updatingScrollbar then
                return
            end
            setScrollOffset(value, true)
        end)
    end

    if createdFromTemplate and not scrollbar then
        debugLog("TrackerHost: ZO_ScrollContainer template missing ScrollBar child")
    end

    scrollContainer:SetHandler("OnMouseWheel", function(_, delta)
        adjustScroll(delta)
    end)

    state.scrollContainer = scrollContainer
    state.scrollContent = scrollContent
    state.scrollbar = scrollbar
    state.scrollContentLeftOffset = 0
    state.scrollContentRightOffset = 0
    state.scrollOffset = 0
    state.desiredScrollOffset = 0
    state.scrollMaxOffset = 0

    state.appearance = ensureAppearanceSettings()
    applyViewportPadding()
end

local function createResizeGrip()
    if state.resizeGrips or not (state.root and WINDOW_MANAGER) then
        return
    end

    local function attachGripHandlers(grip, mode)
        if not grip then
            return
        end

        grip:SetMouseEnabled(true)

        grip:SetHandler("OnMouseDown", function(_, button)
            if button ~= LEFT_MOUSE_BUTTON then
                return
            end

            beginResize(mode)
        end)

        grip:SetHandler("OnMouseUp", function(_, button)
            if button == LEFT_MOUSE_BUTTON then
                endResize()
            end
        end)
    end

    local function attachHoverHandlers(grip, mode)
        if not grip then
            return
        end

        grip:SetHandler("OnMouseEnter", function()
            if not mode then
                return
            end

            local allowH = IsHorizontalResizeAllowed()
            local allowV = IsVerticalResizeAllowed()
            if not IsResizeModeEnabled(mode, allowH, allowV) then
                return
            end

            if mode == "left" or mode == "right" then
                if allowH then
                    SetResizeCursor("horizontal")
                end
            elseif mode == "top" or mode == "bottom" then
                if allowV then
                    SetResizeCursor("vertical")
                end
            elseif mode == "topleft" or mode == "bottomright" then
                if allowH and allowV then
                    SetResizeCursor("nwse")
                elseif allowH then
                    SetResizeCursor("horizontal")
                elseif allowV then
                    SetResizeCursor("vertical")
                end
            elseif mode == "topright" or mode == "bottomleft" then
                if allowH and allowV then
                    SetResizeCursor("nesw")
                elseif allowH then
                    SetResizeCursor("horizontal")
                elseif allowV then
                    SetResizeCursor("vertical")
                end
            end
        end)

        grip:SetHandler("OnMouseExit", function()
            if not resizeState.active then
                ResetResizeCursor()
            end
        end)
    end

    local function applyCornerTexture(control, rotation)
        if not control then
            return
        end

        local texture = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
        if not texture then
            return
        end

        texture:SetAnchorFill()
        texture:SetTexture("EsoUI/Art/ChatWindow/chat_resizeGrip.dds")
        texture:SetColor(1, 1, 1, 0.75)
        if rotation and texture.SetTextureRotation then
            texture:SetTextureRotation(rotation)
        end
    end

    local grips = {}
    local CORNER_CLEARANCE = RESIZE_GRIP_SIZE + 4

    local cornerBR = WINDOW_MANAGER:CreateControl(RESIZE_GRIP_NAME .. "_BottomRight", state.root, CT_CONTROL)
    if cornerBR then
        cornerBR:SetDimensions(RESIZE_GRIP_SIZE, RESIZE_GRIP_SIZE)
        cornerBR:ClearAnchors()
        cornerBR:SetAnchor(BOTTOMRIGHT, state.root, BOTTOMRIGHT, -4, -4)
        cornerBR:SetDrawLayer(DL_OVERLAY)
        cornerBR:SetDrawTier(DT_LOW)
        cornerBR:SetDrawLevel(1)

        applyCornerTexture(cornerBR, 0)

        attachGripHandlers(cornerBR, "bottomright")
        attachHoverHandlers(cornerBR, "bottomright")
        grips.bottomright = cornerBR
    end

    local cornerTR = WINDOW_MANAGER:CreateControl(RESIZE_GRIP_NAME .. "_TopRight", state.root, CT_CONTROL)
    if cornerTR then
        cornerTR:SetDimensions(RESIZE_GRIP_SIZE, RESIZE_GRIP_SIZE)
        cornerTR:ClearAnchors()
        cornerTR:SetAnchor(TOPRIGHT, state.root, TOPRIGHT, -4, 4)
        cornerTR:SetDrawLayer(DL_OVERLAY)
        cornerTR:SetDrawTier(DT_LOW)
        cornerTR:SetDrawLevel(1)

        applyCornerTexture(cornerTR, math.pi * 0.5)

        attachGripHandlers(cornerTR, "topright")
        attachHoverHandlers(cornerTR, "topright")
        grips.topright = cornerTR
    end

    local cornerBL = WINDOW_MANAGER:CreateControl(RESIZE_GRIP_NAME .. "_BottomLeft", state.root, CT_CONTROL)
    if cornerBL then
        cornerBL:SetDimensions(RESIZE_GRIP_SIZE, RESIZE_GRIP_SIZE)
        cornerBL:ClearAnchors()
        cornerBL:SetAnchor(BOTTOMLEFT, state.root, BOTTOMLEFT, 4, -4)
        cornerBL:SetDrawLayer(DL_OVERLAY)
        cornerBL:SetDrawTier(DT_LOW)
        cornerBL:SetDrawLevel(1)

        applyCornerTexture(cornerBL, math.pi * 1.5)

        attachGripHandlers(cornerBL, "bottomleft")
        attachHoverHandlers(cornerBL, "bottomleft")
        grips.bottomleft = cornerBL
    end

    local cornerTL = WINDOW_MANAGER:CreateControl(RESIZE_GRIP_NAME .. "_TopLeft", state.root, CT_CONTROL)
    if cornerTL then
        cornerTL:SetDimensions(RESIZE_GRIP_SIZE, RESIZE_GRIP_SIZE)
        cornerTL:ClearAnchors()
        cornerTL:SetAnchor(TOPLEFT, state.root, TOPLEFT, 4, 4)
        cornerTL:SetDrawLayer(DL_OVERLAY)
        cornerTL:SetDrawTier(DT_LOW)
        cornerTL:SetDrawLevel(1)

        applyCornerTexture(cornerTL, math.pi)

        attachGripHandlers(cornerTL, "topleft")
        attachHoverHandlers(cornerTL, "topleft")
        grips.topleft = cornerTL
    end

    local bottom = WINDOW_MANAGER:CreateControl(RESIZE_GRIP_NAME .. "_Bottom", state.root, CT_CONTROL)
    if bottom then
        bottom:ClearAnchors()
        bottom:SetAnchor(BOTTOMLEFT, state.root, BOTTOMLEFT, CORNER_CLEARANCE, 0)
        bottom:SetAnchor(BOTTOMRIGHT, state.root, BOTTOMRIGHT, -CORNER_CLEARANCE, 0)
        bottom:SetHeight(RESIZE_BORDER_THICKNESS)
        bottom:SetDrawLayer(DL_OVERLAY)
        bottom:SetDrawTier(DT_LOW)
        bottom:SetDrawLevel(0)
        if bottom.SetAlpha then
            bottom:SetAlpha(0)
        end

        attachGripHandlers(bottom, "bottom")
        attachHoverHandlers(bottom, "bottom")
        grips.bottom = bottom
    end

    local right = WINDOW_MANAGER:CreateControl(RESIZE_GRIP_NAME .. "_Right", state.root, CT_CONTROL)
    if right then
        right:ClearAnchors()
        right:SetAnchor(TOPRIGHT, state.root, TOPRIGHT, 0, CORNER_CLEARANCE)
        right:SetAnchor(BOTTOMRIGHT, state.root, BOTTOMRIGHT, 0, -CORNER_CLEARANCE)
        right:SetWidth(RESIZE_BORDER_THICKNESS)
        right:SetDrawLayer(DL_OVERLAY)
        right:SetDrawTier(DT_LOW)
        right:SetDrawLevel(0)
        if right.SetAlpha then
            right:SetAlpha(0)
        end

        attachGripHandlers(right, "right")
        attachHoverHandlers(right, "right")
        grips.right = right
    end

    local top = WINDOW_MANAGER:CreateControl(RESIZE_GRIP_NAME .. "_Top", state.root, CT_CONTROL)
    if top then
        top:ClearAnchors()
        top:SetAnchor(TOPLEFT, state.root, TOPLEFT, CORNER_CLEARANCE, 0)
        top:SetAnchor(TOPRIGHT, state.root, TOPRIGHT, -CORNER_CLEARANCE, 0)
        top:SetHeight(RESIZE_BORDER_THICKNESS)
        top:SetDrawLayer(DL_OVERLAY)
        top:SetDrawTier(DT_LOW)
        top:SetDrawLevel(0)
        if top.SetAlpha then
            top:SetAlpha(0)
        end

        attachGripHandlers(top, "top")
        attachHoverHandlers(top, "top")
        grips.top = top
    end

    local left = WINDOW_MANAGER:CreateControl(RESIZE_GRIP_NAME .. "_Left", state.root, CT_CONTROL)
    if left then
        left:ClearAnchors()
        left:SetAnchor(TOPLEFT, state.root, TOPLEFT, 0, CORNER_CLEARANCE)
        left:SetAnchor(BOTTOMLEFT, state.root, BOTTOMLEFT, 0, -CORNER_CLEARANCE)
        left:SetWidth(RESIZE_BORDER_THICKNESS)
        left:SetDrawLayer(DL_OVERLAY)
        left:SetDrawTier(DT_LOW)
        left:SetDrawLevel(0)
        if left.SetAlpha then
            left:SetAlpha(0)
        end

        attachGripHandlers(left, "left")
        attachHoverHandlers(left, "left")
        grips.left = left
    end

    if not next(grips) then
        return
    end

    state.resizeGrips = grips
    state.window = state.window or ensureWindowSettings()

    if state.window and state.window.locked == true then
        for _, grip in pairs(grips) do
            if grip then
                if grip.SetMouseEnabled then
                    grip:SetMouseEnabled(false)
                end
                if grip.SetHidden then
                    grip:SetHidden(true)
                end
            end
        end
    end
end

local function SafeCreateSectionContainer(name, parent)
    if not (WINDOW_MANAGER and parent and name) then
        return nil
    end

    if _G[SECTION_TEMPLATE_NAME] and WINDOW_MANAGER.CreateControlFromVirtual then
        local ok, control = pcall(
            WINDOW_MANAGER.CreateControlFromVirtual,
            WINDOW_MANAGER,
            name,
            parent,
            SECTION_TEMPLATE_NAME
        )
        if ok and control then
            return control
        end
    end

    local fallback = nil
    if WINDOW_MANAGER.CreateControl then
        fallback = WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)
    end
    if fallback then
        if fallback.SetResizeToFitDescendents then
            fallback:SetResizeToFitDescendents(true)
        end
        if fallback.SetHidden then
            fallback:SetHidden(true)
        end
    end

    local warnMessage = string.format(
        "TrackerHost: Section template missing; created plain container for %s",
        tostring(name)
    )
    if Nvk3UT and type(Nvk3UT.Warn) == "function" then
        Nvk3UT.Warn(warnMessage)
    else
        debugLog(warnMessage)
    end

    return fallback
end

local function createContainers()
    if not (state.root and WINDOW_MANAGER) then
        return
    end

    TrackerHost.sectionContainers = TrackerHost.sectionContainers or {}
    local globalHost = Nvk3UT and type(Nvk3UT.TrackerHost) == "table" and Nvk3UT.TrackerHost
    if globalHost then
        globalHost.sectionContainers = globalHost.sectionContainers or TrackerHost.sectionContainers
    end

    if not state.clientArea then
        local clientArea = WINDOW_MANAGER:CreateControl(nil, state.root, CT_CONTROL)
        if clientArea then
            clientArea:SetAnchor(TOPLEFT, state.root, TOPLEFT, RESIZE_BORDER_THICKNESS, RESIZE_BORDER_THICKNESS)
            clientArea:SetAnchor(BOTTOMRIGHT, state.root, BOTTOMRIGHT, -RESIZE_BORDER_THICKNESS, -RESIZE_BORDER_THICKNESS)
            clientArea:SetMouseEnabled(false)
            if clientArea.SetExcludeFromResizeToFitExtents then
                clientArea:SetExcludeFromResizeToFitExtents(true)
            end
            state.clientArea = clientArea
        end
    end

    createDragLayer()
    createScrollContainer()
    createResizeGrip()

    state.windowBars = ensureWindowBarSettings()

    local bars = state.windowBars

    local scrollContent = state.scrollContent or state.root
    if not scrollContent then
        return
    end

    local headerBar = state.headerBar or _G[HEADER_BAR_NAME]
    if not headerBar then
        headerBar = WINDOW_MANAGER:CreateControl(HEADER_BAR_NAME, scrollContent, CT_CONTROL)
    else
        headerBar:SetParent(scrollContent)
    end
    if headerBar then
        headerBar:SetMouseEnabled(true)
        headerBar:SetHandler("OnMouseWheel", function(_, delta)
            adjustScroll(delta)
        end)
        attachDragHandlers(headerBar)
        local headerHeight = clamp(tonumber(bars.headerHeightPx) or DEFAULT_WINDOW_BARS.headerHeightPx, 0, MAX_BAR_HEIGHT)
        headerBar:SetHeight(headerHeight)
        if headerBar.SetHidden then
            headerBar:SetHidden(headerHeight <= 0)
        end
        headerBar:SetMouseEnabled(headerHeight > 0)
        state.headerBar = headerBar
    end

    local contentStack = state.contentStack or _G[CONTENT_STACK_NAME]
    if not contentStack then
        contentStack = WINDOW_MANAGER:CreateControl(CONTENT_STACK_NAME, scrollContent, CT_CONTROL)
    else
        contentStack:SetParent(scrollContent)
    end
    if contentStack then
        contentStack:SetMouseEnabled(true)
        if contentStack.SetResizeToFitDescendents then
            contentStack:SetResizeToFitDescendents(false)
        end
        contentStack:SetHandler("OnMouseWheel", function(_, delta)
            adjustScroll(delta)
        end)
        state.contentStack = contentStack
    end

    local footerBar = state.footerBar or _G[FOOTER_BAR_NAME]
    if not footerBar then
        footerBar = WINDOW_MANAGER:CreateControl(FOOTER_BAR_NAME, scrollContent, CT_CONTROL)
    else
        footerBar:SetParent(scrollContent)
    end
    if footerBar then
        footerBar:SetMouseEnabled(true)
        if footerBar.SetResizeToFitDescendents then
            footerBar:SetResizeToFitDescendents(false)
        end
        footerBar:SetHandler("OnMouseWheel", function(_, delta)
            adjustScroll(delta)
        end)
        local footerHeight = clamp(tonumber(bars.footerHeightPx) or DEFAULT_WINDOW_BARS.footerHeightPx, 0, MAX_BAR_HEIGHT)
        footerBar:SetHeight(footerHeight)
        if footerBar.SetHidden then
            footerBar:SetHidden(footerHeight <= 0)
        end
        footerBar:SetMouseEnabled(footerHeight > 0)
        state.footerBar = footerBar
    end

    local contentParent = state.contentStack or scrollContent

    if contentParent then
        local questContainer = state.questContainer or _G[QUEST_CONTAINER_NAME]
        if not questContainer then
            questContainer = WINDOW_MANAGER:CreateControl(QUEST_CONTAINER_NAME, contentParent, CT_CONTROL)
        else
            questContainer:SetParent(contentParent)
        end
        if questContainer then
            questContainer:SetMouseEnabled(false)
            if questContainer.SetResizeToFitDescendents then
                questContainer:SetResizeToFitDescendents(false)
            end
            questContainer:SetHandler("OnMouseWheel", function(_, delta)
                adjustScroll(delta)
            end)
            state.questContainer = questContainer
            TrackerHost.questSectionContainer = questContainer
            TrackerHost.sectionContainers.quest = questContainer
            if Nvk3UT and type(Nvk3UT.TrackerHost) == "table" then
                Nvk3UT.TrackerHost.sectionContainers = Nvk3UT.TrackerHost.sectionContainers or TrackerHost.sectionContainers
                Nvk3UT.TrackerHost.sectionContainers.quest = questContainer
            end
            Nvk3UT.UI.QuestContainer = questContainer
        end
    end

    if contentParent then
        local endeavorContainer = state.endeavorContainer or _G[ENDEAVOR_CONTAINER_NAME]
        if not endeavorContainer then
            endeavorContainer = WINDOW_MANAGER:CreateControl(ENDEAVOR_CONTAINER_NAME, contentParent, CT_CONTROL)
            if endeavorContainer then
                debugLog(string.format(
                    "TrackerHost: Endeavor section container created between Quest and Achievement using '%s'",
                    "CT_CONTROL"
                ))
            end
        else
            endeavorContainer:SetParent(contentParent)
        end
        if endeavorContainer then
            endeavorContainer:SetMouseEnabled(false)
            if endeavorContainer.SetResizeToFitDescendents then
                endeavorContainer:SetResizeToFitDescendents(false)
            end
            endeavorContainer:SetHandler("OnMouseWheel", function(_, delta)
                adjustScroll(delta)
            end)
            state.endeavorContainer = endeavorContainer
            TrackerHost.endeavorSectionContainer = endeavorContainer
            TrackerHost.sectionContainers.endeavor = endeavorContainer
            if Nvk3UT and type(Nvk3UT.TrackerHost) == "table" then
                Nvk3UT.TrackerHost.sectionContainers = Nvk3UT.TrackerHost.sectionContainers or TrackerHost.sectionContainers
                Nvk3UT.TrackerHost.sectionContainers.endeavor = endeavorContainer
            end
            Nvk3UT.UI.EndeavorContainer = endeavorContainer
        end
    end

    if contentParent then
        local achievementContainer = state.achievementContainer or _G[ACHIEVEMENT_CONTAINER_NAME]
        if not achievementContainer then
            achievementContainer = WINDOW_MANAGER:CreateControl(ACHIEVEMENT_CONTAINER_NAME, contentParent, CT_CONTROL)
        else
            achievementContainer:SetParent(contentParent)
        end
        if achievementContainer then
            achievementContainer:SetMouseEnabled(false)
            if achievementContainer.SetResizeToFitDescendents then
                achievementContainer:SetResizeToFitDescendents(false)
            end
            achievementContainer:SetHandler("OnMouseWheel", function(_, delta)
                adjustScroll(delta)
            end)
            state.achievementContainer = achievementContainer
            TrackerHost.achievementSectionContainer = achievementContainer
            TrackerHost.sectionContainers.achievement = achievementContainer
            if Nvk3UT and type(Nvk3UT.TrackerHost) == "table" then
                Nvk3UT.TrackerHost.sectionContainers = Nvk3UT.TrackerHost.sectionContainers or TrackerHost.sectionContainers
                Nvk3UT.TrackerHost.sectionContainers.achievement = achievementContainer
            end
            Nvk3UT.UI.AchievementContainer = achievementContainer
        end
    end

    if contentParent then
        local parentName = contentParent.GetName and contentParent:GetName()
        local goldenName
        if type(parentName) == "string" and parentName ~= "" then
            goldenName = string.format("%sGoldenContainer", parentName)
        else
            goldenName = GOLDEN_CONTAINER_NAME
        end

        local goldenContainer = state.goldenContainer or _G[goldenName] or _G[GOLDEN_CONTAINER_NAME]
        local createdNew = false
        if not goldenContainer then
            goldenContainer = SafeCreateSectionContainer(goldenName, contentParent)
            createdNew = goldenContainer ~= nil
        else
            goldenContainer:SetParent(contentParent)
        end

        if goldenContainer then
            if createdNew then
                if Nvk3UT and type(Nvk3UT.Debug) == "function" then
                    Nvk3UT.Debug("TrackerHost: Golden section container created (safe)")
                else
                    debugLog("TrackerHost: Golden section container created (safe)")
                end
            end

            goldenContainer:SetMouseEnabled(false)
            if goldenContainer.SetResizeToFitDescendents then
                goldenContainer:SetResizeToFitDescendents(false)
            end
            goldenContainer:SetHandler("OnMouseWheel", function(_, delta)
                adjustScroll(delta)
            end)
            state.goldenContainer = goldenContainer
            TrackerHost.goldenSectionContainer = goldenContainer
            TrackerHost.sectionContainers.golden = goldenContainer
            if globalHost then
                globalHost.sectionContainers.golden = goldenContainer
            end
            Nvk3UT.UI.GoldenContainer = goldenContainer
        end
    end

    applyWindowBars()
    refreshScroll()
end

local function updateSectionLayout()
    if not state.root then
        return
    end

    createContainers()
    anchorContainers()
end

applyWindowLock = function()
    if not (state.root and state.window) then
        return
    end

    local locked = state.window.locked == true
    if locked and resizeState.active then
        endResize()
    end
    state.root:SetMovable(not locked)
    state.root:SetResizeHandleSize(locked and 0 or RESIZE_HANDLE_SIZE)

    local grips = state.resizeGrips
    if grips then
        for _, grip in pairs(grips) do
            if grip then
                if grip.SetMouseEnabled then
                    grip:SetMouseEnabled(not locked)
                end
                if grip.SetHidden then
                    grip:SetHidden(locked)
                end
            end
        end
    end
end

local function applyWindowVisibility()
    if not state.root then
        return true
    end

    local userHidden = state.window and state.window.visible == false
    local suppressed = state.initializing == true
    local gates = ensureVisibilityGates()
    local lamOverrideActive = gates.lam == true and not userHidden
    local hideForSceneGate = gates.scene == true
    local hideForCombatGate = gates.combat == true
    local previewActive = state.lamPreviewForceVisible == true and not userHidden
    local shouldHideForSettings = suppressed or userHidden

    if (previewActive or lamOverrideActive) and not userHidden then
        shouldHideForSettings = false
    end

    local fragment = state.fragment
    local fragmentSupportsReason = fragment and fragment.SetHiddenForReason
    local hideForScene = hideForSceneGate and not lamOverrideActive
    local hideForCombat = hideForCombatGate and not lamOverrideActive
    local hideForSceneOrCombat = hideForScene or hideForCombat

    if fragmentSupportsReason then
        if previewActive or lamOverrideActive then
            fragment:SetHiddenForReason(FRAGMENT_REASON_SUPPRESSED, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_USER, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_SCENE, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_COMBAT, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_LAM, false)
        else
            fragment:SetHiddenForReason(FRAGMENT_REASON_SUPPRESSED, suppressed)
            fragment:SetHiddenForReason(FRAGMENT_REASON_USER, userHidden)
            fragment:SetHiddenForReason(FRAGMENT_REASON_SCENE, hideForScene)
            fragment:SetHiddenForReason(FRAGMENT_REASON_COMBAT, hideForCombat)
            fragment:SetHiddenForReason(FRAGMENT_REASON_LAM, false)
        end
    end

    if shouldHideForSettings then
        state.root:SetHidden(true)
    elseif fragmentSupportsReason then
        state.root:SetHidden(false)
    else
        if hideForSceneOrCombat then
            state.root:SetHidden(true)
        else
            state.root:SetHidden(false)
        end
    end

    if lamPreview.active and previewActive then
        lamPreview.windowPreviewApplied = true
    end

    return shouldHideForSettings or hideForSceneOrCombat
end

function TrackerHost.ApplyVisibilityRules()
    local windowSettings = state.window or ensureWindowSettings()
    local hostSettings = getHostSettings()
    local previousSceneHidden = state.sceneHidden == true
    local previousVisible = TrackerHost.IsVisible()

    local userVisible = not (windowSettings and windowSettings.visible == false)
    if not userVisible then
        state.sceneHidden = true

        local fragment = state.fragment
        if fragment and fragment.SetHiddenForReason then
            fragment:SetHiddenForReason(FRAGMENT_REASON_SUPPRESSED, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_USER, true)
            fragment:SetHiddenForReason(FRAGMENT_REASON_SCENE, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_COMBAT, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_LAM, false)
        end

        if state.root then
            state.root:SetHidden(true)
        end

        return previousSceneHidden ~= (state.sceneHidden == true)
    end

    local gates = refreshVisibilityGates(hostSettings)
    local lamOverride = gates.lam == true
    local hideForScene = gates.scene == true
    local hideForCombat = gates.combat == true

    local applyLabel
    if lamOverride then
        applyLabel = "LAM override"
    elseif hideForScene then
        applyLabel = "scene"
    elseif hideForCombat then
        applyLabel = "combat"
    else
        applyLabel = "hud"
    end

    visibilityDebug(
        "Host gates: scene=%s combat=%s lam=%s → apply=%s",
        tostring(hideForScene),
        tostring(hideForCombat),
        tostring(lamOverride),
        applyLabel
    )

    if lamOverride then
        state.sceneHidden = false
    else
        local effectiveSceneHidden = hideForScene == true
        local effectiveCombatHidden = hideForCombat == true
        state.sceneHidden = effectiveSceneHidden or effectiveCombatHidden
    end

    applyWindowVisibility()

    local sectionVisibilityChanged = applyTrackerSectionVisibility()

    local changed = previousSceneHidden ~= (state.sceneHidden == true)
        or sectionVisibilityChanged
    if changed then
        visibilityDebug(
            "Host visibility -> %s (%s)",
            state.sceneHidden and "hidden" or "visible",
            applyLabel
        )
    end

    local nowVisible = TrackerHost.IsVisible()
    if not previousVisible and nowVisible then
        requestPendingFullRebuild()
        triggerDeferredFullRebuildOnVisible()
        requestHostFullRebuild("sceneVisible:ApplyVisibilityRules")
    end

    return changed
end

local function refreshWindowLayout(targetOffset)
    if not state.root then
        return
    end

    ensureSceneFragment(state.root)
    updateWindowGeometry()
    applyWindowVisibility()
    refreshScroll(targetOffset)
    applyCollapsedVisibility()
end

local function scheduleDeferredRefresh(targetOffset)
    if not (zo_callLater and state.root) then
        return
    end

    state.pendingDeferredOffset = targetOffset

    if state.deferredRefreshScheduled then
        return
    end

    state.deferredRefreshScheduled = true

    zo_callLater(function()
        state.deferredRefreshScheduled = false

        if not state.root then
            return
        end

        local offset = state.pendingDeferredOffset
        state.pendingDeferredOffset = nil

        refreshWindowLayout(offset)
    end, 0)
end

local function scrollControlIntoView(control)
    if not control then
        return false, false
    end

    local scrollContainer = state.scrollContainer
    local scrollContent = state.scrollContent
    if not (scrollContainer and scrollContent) then
        return false, false
    end

    if control.IsHidden and control:IsHidden() then
        return false, false
    end

    if not (control.GetTop and control.GetBottom) then
        return false, false
    end

    if not (scrollContent.GetTop and scrollContainer.GetHeight) then
        return false, false
    end

    local controlTop = control:GetTop()
    local controlBottom = control:GetBottom()
    local contentTop = scrollContent:GetTop()
    local containerHeight = scrollContainer:GetHeight()

    if not (controlTop and controlBottom and contentTop and containerHeight) then
        return false, false
    end

    if containerHeight <= 0 then
        return false, false
    end

    local desiredOffset = state.desiredScrollOffset
    if desiredOffset == nil then
        desiredOffset = state.scrollOffset or 0
    end
    desiredOffset = desiredOffset or 0

    local relativeTop = controlTop - contentTop
    local relativeBottom = controlBottom - contentTop

    local targetOffset = desiredOffset
    if targetOffset > relativeTop then
        targetOffset = relativeTop
    end

    if (relativeBottom - targetOffset) > containerHeight then
        targetOffset = relativeBottom - containerHeight
    end

    if targetOffset < 0 then
        targetOffset = 0
    end

    local actualOffset = state.scrollOffset or 0
    if math.abs(actualOffset - targetOffset) < 0.1 then
        return true, false
    end

    setScrollOffset(targetOffset)
    scheduleDeferredRefresh(targetOffset)

    return true, true
end

performLocalWindowRefresh = function()
    if not state.root then
        return
    end

    local preservedOffset = getCurrentScrollOffset()

    refreshWindowLayout(preservedOffset)
    scheduleDeferredRefresh(preservedOffset)
end

performFullHostRefresh = function(reason)
    local addonRoot = type(Nvk3UT) == "table" and Nvk3UT or nil
    if addonRoot and addonRoot._rebuild_lock then
        return
    end

    local rebuild = (addonRoot and addonRoot.Rebuild) or _G.Nvk3UT_Rebuild
    local rebuildAll = rebuild and rebuild.All
    if type(rebuildAll) == "function" then
        local context = "hostRefresh"
        if reason ~= nil and reason ~= "" then
            context = string.format("hostRefresh:%s", tostring(reason))
        end

        safeCall(rebuildAll, context)
        return
    end

    if performLocalWindowRefresh then
        performLocalWindowRefresh()
    end
end

local function notifyContentChanged()
    performLocalWindowRefresh()
end

local function applyWindowClamp()
    if not (state.root and state.window) then
        return
    end

    local clampToScreen = state.window.clamp ~= false
    state.root:SetClampedToScreen(clampToScreen)

    if clampToScreen then
        clampWindowToScreen(state.window.width or DEFAULT_WINDOW.width, state.window.height or DEFAULT_WINDOW.height)
    end
end

local function applyWindowTopmost()
    if not (state.root and state.window) then
        return
    end

    local onTop = state.window.onTop == true
    if state.root.SetTopmostWindow then
        state.root:SetTopmostWindow(onTop)
    end
    if state.root.SetTopmost then
        state.root:SetTopmost(onTop)
    end
    if state.root.SetDrawLayer then
        state.root:SetDrawLayer(onTop and DL_OVERLAY or DL_BACKGROUND)
    end
    if state.root.SetDrawTier then
        state.root:SetDrawTier(onTop and DT_HIGH or DT_LOW)
    end

    if state.backdrop then
        if state.backdrop.SetDrawLayer then
            state.backdrop:SetDrawLayer(onTop and DL_OVERLAY or DL_BACKGROUND)
        end
        if state.backdrop.SetDrawTier then
            state.backdrop:SetDrawTier(onTop and DT_HIGH or DT_LOW)
        end
    end

end

local function applyWindowSettings()
    state.hostSettings = ensureHostSettings()
    state.window = ensureWindowSettings()
    state.appearance = ensureAppearanceSettings()
    state.layout = ensureLayoutSettings()
    state.features = ensureFeatureSettings()
    state.windowBars = ensureWindowBarSettings()

    if not state.root then
        return
    end

    createContainers()
    ensureCornerButton()

    applyWindowBars()
    applyLayoutConstraints()
    updateSectionLayout()
    applyWindowClamp()
    updateWindowGeometry()
    applyWindowLock()
    applyWindowTopmost()
    ensureSceneFragment(state.root)
    applyWindowVisibility()
    refreshScroll()
    applyCollapsedVisibility()
end

local function createBackdrop()
    if state.backdrop or not (state.root and WINDOW_MANAGER) then
        return
    end

    local control = WINDOW_MANAGER:CreateControl(nil, state.root, CT_BACKDROP)
    control:SetAnchorFill()
    control:SetDrawLayer(DL_BACKGROUND)
    control:SetDrawTier(DT_LOW)
    control:SetDrawLevel(0)
    if control.SetExcludeFromResizeToFitExtents then
        control:SetExcludeFromResizeToFitExtents(true)
    end
    control:SetMouseEnabled(false)
    if control.SetCenterColor then
        control:SetCenterColor(0, 0, 0, 0)
    end
    if control.SetEdgeColor then
        control:SetEdgeColor(0, 0, 0, 0)
    end
    if control.SetEdgeTexture then
        local appearance = state.appearance or ensureAppearanceSettings()
        local thickness = math.max(1, appearance.edgeThickness or DEFAULT_APPEARANCE.edgeThickness)
        control:SetEdgeTexture(
            DEFAULT_BACKDROP_TEXTURE.texture,
            DEFAULT_BACKDROP_TEXTURE.tileSize,
            thickness
        )
        control._nvk3utEdgeThickness = thickness
    end

    state.backdrop = control
end

local function ensureSceneStateCallback(scene)
    if not (scene and scene.RegisterCallback) then
        return
    end

    state.sceneCallbacks = state.sceneCallbacks or {}
    if state.sceneCallbacks[scene] then
        return
    end

    local function onStateChange(_, newState)
        if not state.root then
            return
        end

        if newState == SCENE_SHOWING then
            if zo_callLater then
                zo_callLater(function()
                    if state.root then
                        refreshWindowLayout()
                    end
                end, 0)
            else
                refreshWindowLayout()
            end
        end
    end

    local ok, message = pcall(scene.RegisterCallback, scene, "StateChange", onStateChange)
    if not ok then
        debugLog("Failed to register scene callback", message)
        return
    end

    state.sceneCallbacks[scene] = onStateChange
end

local function attachFragmentToScene(scene)
    if not (scene and state.fragment and scene.AddFragment) then
        return false
    end

    state.fragmentScenes = state.fragmentScenes or {}
    if state.fragmentScenes[scene] then
        return true
    end

    if scene.HasFragment and scene:HasFragment(state.fragment) then
        state.fragmentScenes[scene] = true
        return true
    end

    local success, message = pcall(scene.AddFragment, scene, state.fragment)
    if not success then
        debugLog("Failed to attach fragment", message)
        return false
    end

    state.fragmentScenes[scene] = true
    ensureSceneStateCallback(scene)
    return true
end

local function ensureSceneFragmentInternal(hostRoot)
    local root = hostRoot or state.root
    if not root then
        return
    end

    if not ZO_SimpleSceneFragment then
        return
    end

    local fragment = state.fragment
    if not fragment then
        fragment = ZO_SimpleSceneFragment:New(root)
        if not fragment then
            return
        end

        state.fragment = fragment
        state.fragmentScenes = {}

        if fragment.SetHideOnSceneHidden then
            fragment:SetHideOnSceneHidden(false)
        end
        if fragment.SetHiddenForReason then
            fragment:SetHiddenForReason(FRAGMENT_REASON_SUPPRESSED, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_USER, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_SCENE, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_COMBAT, false)
            fragment:SetHiddenForReason(FRAGMENT_REASON_LAM, false)
        end
    end

    state.fragmentScenes = state.fragmentScenes or {}

    local attached = false
    attached = attachFragmentToScene(HUD_SCENE) or attached
    attached = attachFragmentToScene(HUD_UI_SCENE) or attached

    if SCENE_MANAGER and SCENE_MANAGER.GetScene then
        attached = attachFragmentToScene(SCENE_MANAGER:GetScene("hud")) or attached
        attached = attachFragmentToScene(SCENE_MANAGER:GetScene("hudui")) or attached
    end

    if not attached and zo_callLater and not state.fragmentRetryScheduled then
        state.fragmentRetryScheduled = true
        zo_callLater(function()
            state.fragmentRetryScheduled = false
            ensureSceneFragmentInternal(root)
        end, FRAGMENT_RETRY_DELAY_MS)
    end
end

ensureSceneFragment = ensureSceneFragmentInternal

local function createRootControl()
    if state.root or not WINDOW_MANAGER then
        return
    end

    local control = WINDOW_MANAGER:CreateTopLevelWindow(ROOT_CONTROL_NAME)
    if not control then
        return
    end

    control:SetHidden(true)
    control:SetMouseEnabled(true)
    control:SetMovable(true)
    control:SetClampedToScreen(true)
    control:SetResizeHandleSize(RESIZE_HANDLE_SIZE)
    if control.SetDimensionConstraints then
        control:SetDimensionConstraints(MIN_WIDTH, MIN_HEIGHT)
    end
    control:SetDrawLayer(DL_BACKGROUND)
    control:SetDrawTier(DT_LOW)
    control:SetDrawLevel(0)

    control:SetHandler("OnMoveStop", function()
        if saveWindowPosition then
            saveWindowPosition()
        end
        if performFullHostRefresh then
            performFullHostRefresh("windowMove")
        end
    end)

    control:SetHandler("OnResizeStop", function()
        if saveWindowSize then
            saveWindowSize()
        end
        if performFullHostRefresh then
            performFullHostRefresh("nativeResize")
        end
    end)

    control:SetHandler("OnMouseWheel", function(_, delta)
        adjustScroll(delta)
    end)

    control:SetHandler("OnUpdate", function()
        if resizeState.active then
            updateResize()
        end
    end)

    state.root = control
    Nvk3UT.UI.Root = control

    applyLayoutConstraints()
    createBackdrop()
    ensureSceneFragment(state.root)
    ensureRuntimeInitialized()
end


local function applyAppearance()
    state.appearance = ensureAppearanceSettings()

    local appearance = state.appearance
    local backdrop = state.backdrop

    if backdrop then
        local backgroundEnabled = appearance.enabled ~= false
        local alpha = clamp(appearance.alpha, 0, 1)
        local edgeAlpha = clamp(appearance.edgeAlpha, 0, 1)
        local edgeThickness = math.max(1, appearance.edgeThickness or DEFAULT_APPEARANCE.edgeThickness)
        local borderEnabled = appearance.edgeEnabled ~= false and edgeAlpha > 0

        local shouldShow = backgroundEnabled or borderEnabled
        backdrop:SetHidden(not shouldShow)

        if backdrop.SetEdgeTexture then
            local currentThickness = backdrop._nvk3utEdgeThickness or 0
            if currentThickness ~= edgeThickness then
                backdrop:SetEdgeTexture(
                    DEFAULT_BACKDROP_TEXTURE.texture,
                    DEFAULT_BACKDROP_TEXTURE.tileSize,
                    edgeThickness
                )
                backdrop._nvk3utEdgeThickness = edgeThickness
            end
        end

        if backdrop.SetCenterColor then
            local centerAlpha = backgroundEnabled and alpha or 0
            backdrop:SetCenterColor(0, 0, 0, centerAlpha)
        end

        if backdrop.SetEdgeColor then
            local effectiveEdgeAlpha = borderEnabled and edgeAlpha or 0
            backdrop:SetEdgeColor(0, 0, 0, effectiveEdgeAlpha)
        end

        if backdrop.SetCornerRadius then
            backdrop:SetCornerRadius(appearance.cornerRadius or 0)
        end
    end

    applyViewportPadding()
end

local function initModels()
    local sv = getSavedVars()

    if Nvk3UT.QuestModel and Nvk3UT.QuestModel.Init then
        pcall(Nvk3UT.QuestModel.Init, { saved = sv })
    end

    if Nvk3UT.AchievementModel and Nvk3UT.AchievementModel.Init then
        pcall(Nvk3UT.AchievementModel.Init, { saved = sv })
    end

    local goldenState = Nvk3UT and Nvk3UT.GoldenState
    if type(goldenState) == "table" and type(goldenState.Init) == "function" then
        pcall(goldenState.Init, goldenState, sv)
    end

    local goldenList = Nvk3UT and Nvk3UT.GoldenList
    if type(goldenList) == "table" and type(goldenList.Init) == "function" then
        pcall(goldenList.Init, goldenList, sv)
    end

    local goldenModel = Nvk3UT and Nvk3UT.GoldenModel
    if type(goldenModel) == "table" and type(goldenModel.Init) == "function" then
        pcall(goldenModel.Init, goldenModel, sv, goldenState, goldenList)
    end
end

local function initTrackers()
    local sv = getSavedVars()
    if not sv then
        return
    end

    local questOpts = cloneTable(sv.QuestTracker or {})
    if Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.Init and state.questContainer then
        pcall(Nvk3UT.QuestTracker.Init, state.questContainer, questOpts)
    end

    local endeavorOpts = cloneTable(sv.EndeavorTracker or {})
    local endeavorModuleLabel = nil
    if state.endeavorContainer then
        endeavorModuleLabel = safeCall(function()
            local facade = rawget(Nvk3UT, "Endeavor")
            if type(facade) == "table" and type(facade.Init) == "function" then
                facade.Init(state.endeavorContainer)
                return "facade"
            end

            local tracker = rawget(Nvk3UT, "EndeavorTracker") or getEndeavorModule()
            if type(tracker) == "table" and type(tracker.Init) == "function" then
                tracker.Init(state.endeavorContainer, endeavorOpts)
                return "tracker"
            end

            return nil
        end)
    end

    if endeavorModuleLabel then
        debugLog(string.format("Host.Init: Endeavor wired via %s", endeavorModuleLabel))
    end

    local achievementOpts = cloneTable(sv.AchievementTracker or {})
    if Nvk3UT.AchievementTracker and Nvk3UT.AchievementTracker.Init and state.achievementContainer then
        pcall(Nvk3UT.AchievementTracker.Init, Nvk3UT.AchievementTracker, state.achievementContainer, achievementOpts)
    end

    if Nvk3UT and Nvk3UT.QuestTracker and type(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility) == "function" then
        pcall(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility)
    elseif Nvk3UT and type(Nvk3UT.ApplyBaseQuestTrackerVisibility) == "function" then
        pcall(Nvk3UT.ApplyBaseQuestTrackerVisibility)
    end

    local goldenTracker = Nvk3UT and Nvk3UT.GoldenTracker
    local sectionRegistry = Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.sectionContainers
    local goldenContainer = sectionRegistry and sectionRegistry.golden or state.goldenContainer

    if type(goldenTracker) == "table" and type(goldenTracker.Init) == "function" and goldenContainer then
        local safeInvoke = Nvk3UT and Nvk3UT.SafeCall
        local function initGolden()
            local goldenOpts = cloneTable(sv.GoldenTracker or {})
            if goldenContainer then
                local parentName = goldenContainer.GetParent and goldenContainer:GetParent() and goldenContainer:GetParent():GetName() or "<nil>"
                local isHidden = goldenContainer.IsHidden and goldenContainer:IsHidden() or false
                if Nvk3UT and Nvk3UT.Diagnostics and type(Nvk3UT.Diagnostics.DebugIfEnabled) == "function" then
                    Nvk3UT.Diagnostics:DebugIfEnabled(
                        "TrackerHost",
                        "initGolden: container=%s parent=%s hidden=%s",
                        goldenContainer.GetName and goldenContainer:GetName() or "<nil>",
                        parentName,
                        tostring(isHidden)
                    )
                elseif type(debugLog) == "function" then
                    debugLog(
                        "TrackerHost: initGolden container=%s parent=%s hidden=%s",
                        goldenContainer.GetName and goldenContainer:GetName() or "<nil>",
                        parentName,
                        tostring(isHidden)
                    )
                end
            end
            goldenTracker.Init(goldenContainer, goldenOpts)
            if Nvk3UT and type(Nvk3UT.Debug) == "function" then
                Nvk3UT.Debug("TrackerHost: GoldenTracker Init shim complete")
            else
                debugLog("TrackerHost: GoldenTracker Init shim complete")
            end
        end

        if type(safeInvoke) == "function" then
            safeInvoke(initGolden)
        else
            safeCall(initGolden)
        end
    else
        local warnMessage = "TrackerHost: GoldenTracker or container missing during init"
        if Nvk3UT and type(Nvk3UT.Warn) == "function" then
            Nvk3UT.Warn(warnMessage)
        else
            debugLog(warnMessage)
        end
    end

    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if runtime and type(runtime.QueueDirty) == "function" then
        safeCall(function()
            runtime:QueueDirty("endeavor")
        end)

        if endeavorModuleLabel == "facade" then
            debugLog("Host.Init: Endeavor wired via facade and queued initial dirty")
        elseif endeavorModuleLabel then
            debugLog(string.format("Host.Init: Endeavor wired via %s and queued initial dirty", endeavorModuleLabel))
        else
            debugLog("Host.Init: Endeavor queued initial dirty (module unavailable)")
        end
    end
end

function TrackerHost.Init()
    if state.initialized then
        return
    end

    if not getSavedVars() then
        return
    end

    snapshotEndeavorExpandedAtInit()

    state.initializing = true

    state.hostSettings = ensureHostSettings()
    state.window = ensureWindowSettings()
    state.appearance = ensureAppearanceSettings()
    state.layout = ensureLayoutSettings()
    state.features = ensureFeatureSettings()
    TrackerHost.EnsureAppearanceDefaults()

    TrackerHost.ApplySectionOrderFromSettings(false)

    createRootControl()
    createContainers()

    if state.questContainer and state.questContainer.SetHeight then
        local measured = Num0(
            state.questContainer
            and state.questContainer.GetHeight
            and state.questContainer:GetHeight()
        )
        state.questContainer:SetHeight(math.max(0, measured))
    end
    if state.endeavorContainer and state.endeavorContainer.SetHeight then
        local measured = Num0(
            state.endeavorContainer
            and state.endeavorContainer.GetHeight
            and state.endeavorContainer:GetHeight()
        )
        state.endeavorContainer:SetHeight(math.max(0, measured))
    end
    if state.achievementContainer and state.achievementContainer.SetHeight then
        local measured = Num0(
            state.achievementContainer
            and state.achievementContainer.GetHeight
            and state.achievementContainer:GetHeight()
        )
        state.achievementContainer:SetHeight(math.max(0, measured))
    end

    applyWindowSettings()

    initModels()

    local goldenController = Nvk3UT and Nvk3UT.GoldenTrackerController
    if type(goldenController) == "table" then
        local applyFromSettings = goldenController.ApplyBaseGameTrackerVisibilityFromSettings
        if type(applyFromSettings) == "function" then
            pcall(applyFromSettings)
        elseif type(goldenController.ApplyBaseGameTrackerVisibility) == "function" then
            local shouldHide = true
            if type(goldenController.ShouldHideBaseGameTracking) == "function" then
                local ok, result = pcall(goldenController.ShouldHideBaseGameTracking)
                if ok and result ~= nil then
                    shouldHide = result ~= false
                end
            end
            pcall(goldenController.ApplyBaseGameTrackerVisibility, shouldHide)
        end
    end

    initTrackers()

    TrackerHost.ApplySettings()
    TrackerHost.ApplyTheme()

    if Nvk3UT.UI and Nvk3UT.UI.BuildLAM then
        Nvk3UT.UI.BuildLAM()
    elseif Nvk3UT.LAM and Nvk3UT.LAM.Build then
        Nvk3UT.LAM.Build(addonName)
    end

    if TrackerHost.Refresh then
        pcall(TrackerHost.Refresh)
    end

    state.initialized = true
    state.initializing = false

    -- After initial layout/state is applied, schedule a delayed full host
    -- refresh so the first visible frame matches a manual rebuild without
    -- causing immediate re-entry into the rebuild pipeline.
    if not state.initFullRefreshScheduled then
        state.initFullRefreshScheduled = true

        if zo_callLater and performFullHostRefresh then
            zo_callLater(function()
                if state.root and performFullHostRefresh then
                    performFullHostRefresh("initDelayed")
                end
            end, 1)
        elseif notifyContentChanged then
            notifyContentChanged()
        end
    end

    ensureSceneFragment(state.root)

    ensureBootstraps()

    state.isInHUDScene = isGameHUDActive()
    state.isInCombat = state.bootstrapCombatState == true
    if TrackerHost.ApplyVisibilityRules() then
        queueRuntimeLayout()
    end

    debugLog("Host window initialized")
end

function TrackerHost.SetVisible(isVisible)
    local visible = isVisible ~= false
    state.window = state.window or ensureWindowSettings()

    local previousVisible = TrackerHost.IsVisible()
    local changed = false

    if state.handlingBootstrapVisibility then
        local previousSceneHidden = state.sceneHidden == true
        state.sceneHidden = not visible
        changed = changed or (previousSceneHidden ~= (state.sceneHidden == true))
    else
        local window = state.window
        local previousSetting = window.visible ~= false
        window.visible = visible
        changed = changed or (previousSetting ~= visible)
    end

    local visibilityChanged
    local appliedViaRules = type(TrackerHost.ApplyVisibilityRules) == "function"

    if appliedViaRules then
        visibilityChanged = TrackerHost.ApplyVisibilityRules()
    elseif state.root then
        applyWindowVisibility()
        visibilityChanged = true
    end

    local newVisible = TrackerHost.IsVisible()
    if not previousVisible and newVisible and not appliedViaRules then
        requestPendingFullRebuild()
        triggerDeferredFullRebuildOnVisible()
    end

    if changed or visibilityChanged or previousVisible ~= newVisible then
        queueRuntimeLayout()
    end

    return newVisible
end

function TrackerHost.IsVisible()
    if state.sceneHidden then
        return false
    end

    if state.root and state.root.IsHidden then
        local hidden = state.root:IsHidden()
        if hidden ~= nil then
            return not hidden
        end
    end

    if state.window and state.window.visible ~= nil then
        return state.window.visible ~= false
    end

    return true
end

function TrackerHost.GetRootWindow()
    return state.root
end

function TrackerHost.SetCornerButtonEnabled(selfOrEnabled, maybeEnabled)
    local enabled = maybeEnabled
    if selfOrEnabled ~= TrackerHost then
        enabled = selfOrEnabled
    end

    local hostSettings = ensureHostSettings()
    hostSettings.CornerButtonEnabled = enabled ~= false

    ensureCornerButton()
    refreshCornerButton()
end

function TrackerHost.SetCornerPosition(selfOrPosition, maybePosition)
    local position = maybePosition
    if selfOrPosition ~= TrackerHost then
        position = selfOrPosition
    end

    local hostSettings = ensureHostSettings()
    hostSettings.CornerPosition = normalizeCornerPosition(position)

    ensureCornerButton()
    refreshCornerButton()
end

function TrackerHost.ApplyContentAlignment(selfOrAlign, maybeAlign)
    local align = maybeAlign
    if selfOrAlign ~= TrackerHost then
        align = selfOrAlign
    end

    local hostSettings = ensureHostSettings()
    local normalized = normalizeContentAlign(align)
    hostSettings.contentAlign = normalized

    TrackerHost.ApplyViewportInsets()

    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if runtime and type(runtime.RequestFullRebuild) == "function" then
        runtime:RequestFullRebuild("TrackerHost.ContentAlign")
    end

    if isDebugEnabled() then
        local leftInset, rightInset, fixApplied = getViewportInsets()
        local scrollbarSide = getScrollbarSide()
        local viewportWidth = TrackerHost.GetViewportWidth()
        local wrapperWidth
        local wrapper = state.contentStack or state.scrollContent
        if wrapper and wrapper.GetWidth then
            local ok, width = pcall(wrapper.GetWidth, wrapper)
            if ok then
                wrapperWidth = tonumber(width) or wrapperWidth
            end
        end

        debugLog(
            "ContentAlign toggle: scrollbarSide=%s contentAlign=%s leftInset=%s rightInset=%s fix=%s viewportWidth=%s wrapperWidth=%s",
            tostring(scrollbarSide),
            tostring(normalized),
            tostring(leftInset),
            tostring(rightInset),
            fixApplied and "20px" or "none",
            tostring(viewportWidth),
            tostring(wrapperWidth)
        )
    end

    return normalized
end

function TrackerHost.SetCollapsed(selfOrCollapsed, maybeCollapsed)
    local collapsed = maybeCollapsed
    if selfOrCollapsed ~= TrackerHost then
        collapsed = selfOrCollapsed
    end

    return setCollapsed(collapsed)
end

function TrackerHost.ToggleCollapsed()
    return setCollapsed(not state.collapsed)
end

function TrackerHost.IsCollapsed()
    return state.collapsed == true
end

function TrackerHost.ApplySettings()
    if not getSavedVars() then
        return
    end

    applyWindowSettings()
    applyFeatureSettings()

    local sv = getSavedVars()

    if Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.ApplySettings then
        pcall(Nvk3UT.QuestTracker.ApplySettings, cloneTable(sv.QuestTracker or {}))
    end

    if Nvk3UT.AchievementTracker and Nvk3UT.AchievementTracker.ApplySettings then
        pcall(Nvk3UT.AchievementTracker.ApplySettings, cloneTable(sv.AchievementTracker or {}))
    end

    TrackerHost.ApplyAppearance()

    if TrackerHost.ApplyVisibilityRules() then
        queueRuntimeLayout()
    end
end

function TrackerHost.ApplyTheme()
    if not getSavedVars() then
        return
    end

    local sv = getSavedVars()

    if Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.ApplyTheme then
        pcall(Nvk3UT.QuestTracker.ApplyTheme, cloneTable(sv.QuestTracker or {}))
    end

    if Nvk3UT.AchievementTracker and Nvk3UT.AchievementTracker.ApplyTheme then
        pcall(Nvk3UT.AchievementTracker.ApplyTheme, cloneTable(sv.AchievementTracker or {}))
    end

    updateSectionLayout()
    TrackerHost.ApplyAppearance()
end

function TrackerHost.ApplyWindowBars()
    if not getSavedVars() then
        return
    end

    applyWindowBars()
    notifyContentChanged()
end

function TrackerHost.Refresh()
    local controller = Nvk3UT and Nvk3UT.QuestTrackerController
    if controller and controller.RequestRefresh then
        pcall(controller.RequestRefresh, controller, "TrackerHost.Refresh")
    else
        local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
        if runtime and runtime.QueueDirty then
            pcall(runtime.QueueDirty, runtime, "quest")
        elseif Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.RequestRefresh then
            pcall(Nvk3UT.QuestTracker.RequestRefresh)
        end
    end

    if Nvk3UT.AchievementTracker then
        if Nvk3UT.AchievementTracker.Refresh then
            pcall(Nvk3UT.AchievementTracker.Refresh, Nvk3UT.AchievementTracker)
        end
    end

    updateSectionLayout()
    notifyContentChanged()
end

function TrackerHost.ApplyAppearance()
    if not state.root then
        return
    end

    applyAppearance()
    notifyContentChanged()
end

function TrackerHost.EnsureAppearanceDefaults()
    return ensureAppearanceColorDefaults()
end

function TrackerHost.GetDefaultTrackerColor(trackerType, role)
    return getDefaultColor(trackerType, role)
end

function TrackerHost.GetTrackerColor(trackerType, role)
    local fallbackR, fallbackG, fallbackB, fallbackA = getDefaultColor(trackerType, role)
    local appearance = ensureAppearanceColorDefaults()
    local tracker = appearance and appearance[trackerType]
    local colors = tracker and tracker.colors
    local color = colors and colors[role]
    if not color then
        return fallbackR, fallbackG, fallbackB, fallbackA
    end

    local r = normalizeColorComponent(color.r, fallbackR)
    local g = normalizeColorComponent(color.g, fallbackG)
    local b = normalizeColorComponent(color.b, fallbackB)
    local a = normalizeColorComponent(color.a, fallbackA)
    return r, g, b, a
end

function TrackerHost.SetTrackerColor(trackerType, role, r, g, b, a)
    if type(trackerType) ~= "string" or type(role) ~= "string" then
        return
    end

    local sv = getSavedVars()
    if not sv then
        return
    end

    local tracker = ensureTrackerColorConfig(sv, trackerType)
    if not tracker then
        return
    end

    tracker.colors = tracker.colors or {}
    local defaultR, defaultG, defaultB, defaultA = getDefaultColor(trackerType, role)
    local color = tracker.colors[role] or {}
    color.r = normalizeColorComponent(r, defaultR)
    color.g = normalizeColorComponent(g, defaultG)
    color.b = normalizeColorComponent(b, defaultB)
    color.a = normalizeColorComponent(a, defaultA)
    tracker.colors[role] = color
end

function TrackerHost.GetDefaultMouseoverHighlightColor(trackerType)
    local defaults = getDefaultMouseoverHighlightColor(trackerType)
    return defaults.r, defaults.g, defaults.b, defaults.a
end

function TrackerHost.GetMouseoverHighlightColor(trackerType)
    return getMouseoverHighlightColor(trackerType)
end

function TrackerHost.SetMouseoverHighlightColor(trackerType, r, g, b, a)
    if type(trackerType) ~= "string" then
        return
    end

    local sv = getSavedVars()
    if not sv then
        return
    end

    local tracker = ensureTrackerColorConfig(sv, trackerType)
    if not tracker then
        return
    end

    tracker.mouseoverHighlightColor = ensureColorComponents(
        {
            r = r,
            g = g,
            b = b,
            a = a,
        },
        getDefaultMouseoverHighlightColor(trackerType)
    )
end

function TrackerHost.OnLamPanelOpened()
    state.isLAMOpen = true
    setVisibilityGate("lam", true)
    lamPreview.active = true
    lamPreview.windowSettingOnOpen = isWindowOptionEnabled()

    if state.root then
        lamPreview.wasWindowVisibleBeforeLAM = not state.root:IsHidden()
    else
        lamPreview.wasWindowVisibleBeforeLAM = nil
    end

    if not lamPreview.windowSettingOnOpen then
        state.lamPreviewForceVisible = false
        lamPreview.windowPreviewApplied = false
        if TrackerHost.ApplyVisibilityRules() then
            queueRuntimeLayout()
        end
        return
    end

    state.lamPreviewForceVisible = true

    if TrackerHost.ApplyWindowBars then
        TrackerHost.ApplyWindowBars()
    end

    if TrackerHost.ApplyAppearance then
        TrackerHost.ApplyAppearance()
    end

    if TrackerHost.Refresh then
        TrackerHost.Refresh()
    end

    if TrackerHost.ApplyVisibilityRules() then
        queueRuntimeLayout()
    end
end

function TrackerHost.OnLamPanelClosed()
    if not lamPreview.active then
        return
    end

    lamPreview.active = false
    state.lamPreviewForceVisible = false
    state.isLAMOpen = false
    setVisibilityGate("lam", false)

    applyWindowVisibility()

    local currentWindowSetting = isWindowOptionEnabled()
    if
        lamPreview.windowPreviewApplied
        and lamPreview.wasWindowVisibleBeforeLAM ~= nil
        and lamPreview.windowSettingOnOpen ~= nil
        and currentWindowSetting == lamPreview.windowSettingOnOpen
        and state.root
    then
        state.root:SetHidden(not lamPreview.wasWindowVisibleBeforeLAM)
    end

    lamPreview.windowPreviewApplied = false
    lamPreview.windowSettingOnOpen = nil
    lamPreview.wasWindowVisibleBeforeLAM = nil

    if TrackerHost.ApplyVisibilityRules() then
        queueRuntimeLayout()
    end
end

function TrackerHost.Shutdown()
    lamPreview.active = false
    lamPreview.windowSettingOnOpen = nil
    lamPreview.wasWindowVisibleBeforeLAM = nil
    lamPreview.windowPreviewApplied = false
    state.lamPreviewForceVisible = false
    state.isLAMOpen = false
    state.isInHUDScene = true
    state.isInCombat = false
    state.visibilityGates = nil

    if state.previousDefaultQuestTrackerHidden ~= nil and ZO_QuestTracker and ZO_QuestTracker.SetHidden then
        ZO_QuestTracker:SetHidden(state.previousDefaultQuestTrackerHidden)
    end

    if Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.Shutdown then
        pcall(Nvk3UT.QuestTracker.Shutdown)
    end

    if Nvk3UT.AchievementTracker and Nvk3UT.AchievementTracker.Shutdown then
        pcall(Nvk3UT.AchievementTracker.Shutdown)
    end

    if Nvk3UT.QuestModel and Nvk3UT.QuestModel.Shutdown then
        pcall(Nvk3UT.QuestModel.Shutdown)
    end

    if Nvk3UT.AchievementModel and Nvk3UT.AchievementModel.Shutdown then
        pcall(Nvk3UT.AchievementModel.Shutdown)
    end

    if state.goldenContainer then
        state.goldenContainer:SetHidden(true)
        state.goldenContainer:SetParent(nil)
    end
    state.goldenContainer = nil
    TrackerHost.goldenSectionContainer = nil
    if TrackerHost.sectionContainers then
        TrackerHost.sectionContainers.golden = nil
    end
    if Nvk3UT.UI then
        Nvk3UT.UI.GoldenContainer = nil
    end

    if state.achievementContainer then
        state.achievementContainer:SetHidden(true)
        state.achievementContainer:SetParent(nil)
    end
    state.achievementContainer = nil
    TrackerHost.achievementSectionContainer = nil
    if TrackerHost.sectionContainers then
        TrackerHost.sectionContainers.achievement = nil
    end
    Nvk3UT.UI.AchievementContainer = nil

    if state.endeavorContainer then
        state.endeavorContainer:SetHidden(true)
        state.endeavorContainer:SetParent(nil)
    end
    state.endeavorContainer = nil
    TrackerHost.endeavorSectionContainer = nil
    if TrackerHost.sectionContainers then
        TrackerHost.sectionContainers.endeavor = nil
    end
    Nvk3UT.UI.EndeavorContainer = nil

    if state.questContainer then
        state.questContainer:SetHidden(true)
        state.questContainer:SetParent(nil)
    end
    state.questContainer = nil
    TrackerHost.questSectionContainer = nil
    if TrackerHost.sectionContainers then
        TrackerHost.sectionContainers.quest = nil
    end
    Nvk3UT.UI.QuestContainer = nil

    if state.footerBar then
        state.footerBar:SetHidden(true)
        state.footerBar:SetParent(nil)
    end
    state.footerBar = nil

    if state.headerBar then
        state.headerBar:SetHidden(true)
        state.headerBar:SetParent(nil)
    end
    state.headerBar = nil

    if state.contentStack then
        state.contentStack:SetHidden(true)
        state.contentStack:SetParent(nil)
    end
    state.contentStack = nil

    if state.scrollbar then
        state.scrollbar:SetHidden(true)
        state.scrollbar:SetHandler("OnValueChanged", nil)
        state.scrollbar:SetParent(nil)
    end
    state.scrollbar = nil

    if state.fragmentScenes and state.fragment then
        for scene in pairs(state.fragmentScenes) do
            if scene and scene.RemoveFragment then
                pcall(scene.RemoveFragment, scene, state.fragment)
            end
        end
    end
    state.fragmentScenes = nil

    if state.sceneCallbacks then
        for scene, callback in pairs(state.sceneCallbacks) do
            if scene and scene.UnregisterCallback and callback then
                pcall(scene.UnregisterCallback, scene, "StateChange", callback)
            end
        end
    end
    state.sceneCallbacks = nil

    if state.bootstrapSceneCallbacks then
        for scene, callback in pairs(state.bootstrapSceneCallbacks) do
            if scene and scene.UnregisterCallback and callback then
                pcall(scene.UnregisterCallback, scene, "StateChange", callback)
            end
        end
    end
    state.bootstrapSceneCallbacks = nil

    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(BOOTSTRAP_NAMESPACE .. "_Cursor", EVENT_CURSOR_MODE_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(BOOTSTRAP_NAMESPACE .. "_Combat", EVENT_PLAYER_COMBAT_STATE)
    end
    state.cursorBootstrapRegistered = false
    state.combatBootstrapRegistered = false
    state.bootstrapsRegistered = false
    state.bootstrapHudVisible = nil
    state.bootstrapCursorMode = nil
    state.bootstrapCombatState = nil
    state.sceneHidden = false
    state.handlingBootstrapVisibility = false
    state.runtimeInitialized = false

    if state.fragment and state.fragment.SetHiddenForReason then
        state.fragment:SetHiddenForReason(FRAGMENT_REASON_SUPPRESSED, true)
        state.fragment:SetHiddenForReason(FRAGMENT_REASON_USER, true)
        state.fragment:SetHiddenForReason(FRAGMENT_REASON_SCENE, false)
        state.fragment:SetHiddenForReason(FRAGMENT_REASON_COMBAT, false)
        state.fragment:SetHiddenForReason(FRAGMENT_REASON_LAM, false)
    end
    state.fragment = nil
    state.fragmentRetryScheduled = false
    state.deferredRefreshScheduled = false
    state.pendingDeferredOffset = nil

    if state.scrollContent then
        state.scrollContent:SetParent(nil)
    end
    state.scrollContent = nil
    state.scrollContentRightOffset = 0
    state.scrollOffset = 0
    state.desiredScrollOffset = 0
    state.scrollMaxOffset = 0
    state.updatingScrollbar = false

    if state.scrollContainer then
        state.scrollContainer:SetHandler("OnMouseWheel", nil)
        state.scrollContainer:SetParent(nil)
    end
    state.scrollContainer = nil

    if state.backdrop then
        state.backdrop:SetHidden(true)
        state.backdrop:SetParent(nil)
    end
    state.backdrop = nil

    if state.cornerButton then
        state.cornerButton:SetHandler("OnMouseEnter", nil)
        state.cornerButton:SetHandler("OnMouseExit", nil)
        state.cornerButton:SetHandler("OnMouseDown", nil)
        state.cornerButton:SetHandler("OnMouseUp", nil)
        state.cornerButton:SetHidden(true)
        state.cornerButton:SetParent(nil)
    end
    state.cornerButton = nil
    state.cornerTexture = nil
    state.cornerHover = false
    state.cornerPressed = false
    state.collapsed = false
    state.expandedWindowSize = nil

    if state.root then
        state.root:SetHandler("OnMoveStop", nil)
        state.root:SetHandler("OnResizeStop", nil)
        state.root:SetHandler("OnMouseWheel", nil)
        state.root:SetHidden(true)
        state.root:SetParent(nil)
    end
    state.root = nil
    Nvk3UT.UI.Root = nil

    if state.anchorWarnings then
        state.anchorWarnings.questMissing = false
        state.anchorWarnings.endeavorMissing = false
        state.anchorWarnings.achievementMissing = false
        state.anchorWarnings.goldenMissing = false
    end

    state.appearance = nil
    state.layout = nil
    state.features = nil
    state.windowBars = nil
    state.initialized = false
    state.previousDefaultQuestTrackerHidden = nil
    state.initializing = false
end

Nvk3UT.TrackerHost = TrackerHost

TrackerHost.RefreshScroll = refreshScroll
TrackerHost.NotifyContentChanged = notifyContentChanged
TrackerHost.ScrollControlIntoView = scrollControlIntoView

function Nvk3UT_ToggleTrackerCollapse()
    local addon = _G and _G.Nvk3UT or Nvk3UT
    if type(addon) ~= "table" then
        return
    end

    local host = addon.TrackerHost
    if type(host) ~= "table" then
        return
    end

    local toggle = host.ToggleCollapsed
    if type(toggle) ~= "function" then
        return
    end

    pcall(toggle, host)
end

function TrackerHost.EnsureVisible(options)
    options = options or {}

    if not state.initialized then
        TrackerHost.Init()
    end

    state.window = ensureWindowSettings()
    TrackerHost.SetVisible(true)
    refreshWindowLayout()

    if options.bringToFront and state.root and state.root.BringWindowToTop then
        pcall(state.root.BringWindowToTop, state.root)
    end

    if options.focus == "achievements" and state.achievementContainer and state.achievementContainer.SetHidden then
        state.achievementContainer:SetHidden(false)
    end

    local isVisible = true
    if state.root and state.root.IsHidden then
        isVisible = not state.root:IsHidden()
    end

    return isVisible ~= false
end

return TrackerHost
