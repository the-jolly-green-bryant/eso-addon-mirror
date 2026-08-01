Nvk3UT = Nvk3UT or {}

local ADDON_NAME = "Nvk3UT"
local DEFAULT_PANEL_TITLE = "Nvk3's Ultimate Tracker"

local L = {}
Nvk3UT.LAM = L

local QuestTracker = Nvk3UT and Nvk3UT.QuestTracker
local QUEST_FILTER_MODE_ALL = (QuestTracker and QuestTracker.QUEST_FILTER_MODE_ALL) or 1
local QUEST_FILTER_MODE_ACTIVE = (QuestTracker and QuestTracker.QUEST_FILTER_MODE_ACTIVE) or 2
local QUEST_FILTER_MODE_SELECTION = (QuestTracker and QuestTracker.QUEST_FILTER_MODE_SELECTION) or 3

local function getAddonVersionString()
    local addon = Nvk3UT
    if type(addon) ~= "table" then
        return nil
    end

    local versionString = addon.versionString or addon.addonVersion
    if type(versionString) == "number" then
        versionString = tostring(versionString)
    elseif type(versionString) ~= "string" then
        versionString = nil
    end

    if versionString == nil or versionString == "" then
        return nil
    end

    local major, minor, patch = versionString:match("(%d+)%.(%d+)%.(%d+)")
    if major and minor and patch then
        return string.format("%d.%d.%d", tonumber(major), tonumber(minor), tonumber(patch))
    end

    return versionString
end

local FONT_FACE_CHOICES = {
    { name = SI_NVK3UT_FONT_FACE_BOLD_DEFAULT, face = "$(BOLD_FONT)" },
    { name = SI_NVK3UT_FONT_FACE_UNIVERS67, face = "EsoUI/Common/Fonts/univers67.otf" },
    { name = SI_NVK3UT_FONT_FACE_UNIVERS57, face = "EsoUI/Common/Fonts/univers57.otf" },
    { name = SI_NVK3UT_FONT_FACE_FUTURA_ANTIQUE, face = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf" },
    { name = SI_NVK3UT_FONT_FACE_HANDWRITTEN, face = "EsoUI/Common/Fonts/Handwritten_Bold.otf" },
    { name = SI_NVK3UT_FONT_FACE_TRAJAN, face = "EsoUI/Common/Fonts/TrajanPro-Regular.otf" },
}

local FONT_FACE_NAMES, FONT_FACE_VALUES = (function()
    local names, values = {}, {}
    for index = 1, #FONT_FACE_CHOICES do
        local stringId = FONT_FACE_CHOICES[index].name
        local localizedName = stringId and GetString(stringId)
        if localizedName == nil or localizedName == "" then
            localizedName = tostring(stringId)
        end

        names[index] = localizedName
        values[index] = FONT_FACE_CHOICES[index].face
    end
    return names, values
end)()

local OUTLINE_CHOICES = {
    { name = SI_NVK3UT_FONT_OUTLINE_NONE, value = "none" },
    { name = SI_NVK3UT_FONT_OUTLINE_SOFT_THIN, value = "soft-shadow-thin" },
    { name = SI_NVK3UT_FONT_OUTLINE_SOFT_THICK, value = "soft-shadow-thick" },
    { name = SI_NVK3UT_FONT_OUTLINE_SHADOW, value = "shadow" },
    { name = SI_NVK3UT_FONT_OUTLINE_OUTLINE, value = "outline" },
}

local function isDebugEnabled()
    local addon = Nvk3UT
    if addon and type(addon.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return addon:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    return false
end

local function debugLog(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local prefix = "[Nvk3UT LAM] "
    local message = prefix .. tostring(fmt)

    if type(fmt) == "string" then
        local ok, formatted = pcall(string.format, prefix .. fmt, ...)
        if ok then
            message = formatted
        end
    end

    if Nvk3UT and type(Nvk3UT.Debug) == "function" then
        Nvk3UT.Debug(message)
    elseif d then
        d(message)
    end
end

local OUTLINE_NAMES, OUTLINE_VALUES = (function()
    local names, values = {}, {}
    for index = 1, #OUTLINE_CHOICES do
        local stringId = OUTLINE_CHOICES[index].name
        local localizedName = stringId and GetString(stringId)
        if localizedName == nil or localizedName == "" then
            localizedName = tostring(stringId)
        end

        names[index] = localizedName
        values[index] = OUTLINE_CHOICES[index].value
    end
    return names, values
end)()

local DEFAULT_FONT_SIZE = {
    quest = { category = 20, title = 16, line = 14 },
    achievement = { category = 20, title = 16, line = 14 },
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

local DEFAULT_LAYOUT = {
    autoGrowV = false,
    autoGrowH = false,
    minWidth = 260,
    minHeight = 240,
    maxWidth = 640,
    maxHeight = 900,
}

local DEFAULT_WINDOW_BARS = {
    headerHeightPx = 40,
    footerHeightPx = 100,
}

local DEFAULT_SPACING = {
    category = { indent = 0, spacingAbove = 3, spacingBelow = 3 },
    entry = { indent = 20, spacingAbove = 0, spacingBelow = 0 },
    objective = { indent = 40, spacingAbove = 3, spacingBelow = 3, spacingBetween = 1 },
}

local DEFAULT_HOST_SETTINGS = {
    HideInCombat = false,
    CornerButtonEnabled = true,
    CornerPosition = "TOP_RIGHT",
    contentAlign = "left",
    scrollbarSide = "right",
    sectionOrder = {
        "questSectionContainer",
        "endeavorSectionContainer",
        "achievementSectionContainer",
        "goldenSectionContainer",
    },
}

local CORNER_POSITION_VALUES = { "TOP_RIGHT", "TOP_LEFT", "BOTTOM_RIGHT", "BOTTOM_LEFT" }
local CORNER_POSITION_CHOICES = {
    GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CORNER_TOP_RIGHT),
    GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CORNER_TOP_LEFT),
    GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CORNER_BOTTOM_RIGHT),
    GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CORNER_BOTTOM_LEFT),
}

local MAX_BAR_HEIGHT = 250

local DEFAULT_SECTION_ORDER_KEYS = {
    "questSectionContainer",
    "endeavorSectionContainer",
    "achievementSectionContainer",
    "goldenSectionContainer",
}

local VALID_SECTION_KEYS = {
    questSectionContainer = true,
    endeavorSectionContainer = true,
    achievementSectionContainer = true,
    goldenSectionContainer = true,
}

local acquireLam

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

local function normalizeCornerPosition(value)
    if type(value) ~= "string" then
        return DEFAULT_HOST_SETTINGS.CornerPosition
    end

    local normalized = value:upper():gsub("%s+", "_"):gsub("%-", "_")
    for index = 1, #CORNER_POSITION_VALUES do
        if normalized == CORNER_POSITION_VALUES[index] then
            return normalized
        end
    end

    return DEFAULT_HOST_SETTINGS.CornerPosition
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

local function getSavedVars()
    return Nvk3UT and Nvk3UT.sv
end

local function getGeneral()
    local sv = getSavedVars()
    sv.General = sv.General or {}
    local general = sv.General
    general.features = general.features or {}
    general.window = general.window or {}
    local window = general.window
    window.left = tonumber(window.left) or DEFAULT_WINDOW.left
    window.top = tonumber(window.top) or DEFAULT_WINDOW.top
    window.width = tonumber(window.width) or DEFAULT_WINDOW.width
    window.height = tonumber(window.height) or DEFAULT_WINDOW.height
    if window.locked == nil then
        window.locked = DEFAULT_WINDOW.locked
    end
    if window.visible == nil then
        window.visible = DEFAULT_WINDOW.visible
    end
    if window.clamp == nil then
        window.clamp = DEFAULT_WINDOW.clamp
    end
    if window.onTop == nil then
        window.onTop = DEFAULT_WINDOW.onTop
    end
    local legacyShowCounts = general.showCategoryCounts
    if general.showQuestCategoryCounts == nil then
        if legacyShowCounts ~= nil then
            general.showQuestCategoryCounts = legacyShowCounts ~= false
        else
            general.showQuestCategoryCounts = true
        end
    end
    if general.showAchievementCategoryCounts == nil then
        if legacyShowCounts ~= nil then
            general.showAchievementCategoryCounts = legacyShowCounts ~= false
        else
            general.showAchievementCategoryCounts = true
        end
    end
    if general.showCategoryCounts == nil then
        general.showCategoryCounts = true
    end
    return general
end

local function getSettings()
    local sv = getSavedVars()
    sv.Settings = sv.Settings or {}
    return sv.Settings
end

local function getDefaultSectionOrder()
    local layout = Nvk3UT and Nvk3UT.TrackerHostLayout
    if layout and type(layout.GetDefaultSectionOrder) == "function" then
        local ok, order = pcall(layout.GetDefaultSectionOrder)
        if ok and type(order) == "table" then
            return order
        end
    end

    local copy = {}
    for index, key in ipairs(DEFAULT_SECTION_ORDER_KEYS) do
        copy[index] = key
    end

    return copy
end

local function normalizeSectionOrder(order)
    local normalized = {}
    local seen = {}

    if type(order) == "table" then
        for _, key in ipairs(order) do
            if VALID_SECTION_KEYS[key] and not seen[key] then
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

local function getHostSettings()
    local settings = getSettings()
    settings.Host = settings.Host or {}
    local host = settings.Host
    if host.HideInCombat == nil then
        host.HideInCombat = DEFAULT_HOST_SETTINGS.HideInCombat
    else
        host.HideInCombat = host.HideInCombat == true
    end

    if host.CornerButtonEnabled == nil then
        host.CornerButtonEnabled = DEFAULT_HOST_SETTINGS.CornerButtonEnabled
    else
        host.CornerButtonEnabled = host.CornerButtonEnabled ~= false
    end

    host.CornerPosition = normalizeCornerPosition(host.CornerPosition)
    host.contentAlign = normalizeContentAlign(host.contentAlign)
    host.scrollbarSide = normalizeScrollbarSide(host.scrollbarSide)
    host.sectionOrder = normalizeSectionOrder(host.sectionOrder)

    return host
end

local function getCurrentSectionOrder()
    local host = getHostSettings()
    host.sectionOrder = normalizeSectionOrder(host.sectionOrder)
    return host.sectionOrder
end

local function applySectionOrder(order)
    local hostOrder = normalizeSectionOrder(order)
    local hostSettings = getHostSettings()
    hostSettings.sectionOrder = hostOrder

    local layout = Nvk3UT and Nvk3UT.TrackerHostLayout
    if layout and type(layout.SetSectionOrder) == "function" then
        local applied = layout.SetSectionOrder(hostOrder)
        if type(applied) == "table" then
            hostSettings.sectionOrder = applied
        end
    end

    local trackerHost = Nvk3UT and Nvk3UT.TrackerHost
    if trackerHost then
        if type(trackerHost.ApplySectionOrderFromSettings) == "function" then
            trackerHost.ApplySectionOrderFromSettings()
        elseif type(trackerHost.Refresh) == "function" then
            trackerHost.Refresh()
        end
    end

    local LAM = acquireLam()
    if LAM and LAM.util and type(LAM.util.RequestRefreshIfNeeded) == "function" and L._panelControl then
        LAM.util.RequestRefreshIfNeeded(L._panelControl)
    end
end

local function buildTrackerOrderControls()
    local controls = {}
    controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_TRACKER_HOST_ORDER) }

    local trackerOrderNames = {
        GetString(SI_NVK3UT_LAM_QUEST_SECTION),
        GetString(SI_NVK3UT_LAM_ENDEAVOR_SECTION),
        GetString(SI_NVK3UT_LAM_ACHIEVEMENT_SECTION),
        GetString(SI_NVK3UT_LAM_GOLDEN_SECTION),
    }
    local trackerOrderValues = getDefaultSectionOrder()
    local trackerSlotLabels = {
        GetString(SI_NVK3UT_LAM_TRACKER_HOST_ORDER_POSITION_1),
        GetString(SI_NVK3UT_LAM_TRACKER_HOST_ORDER_POSITION_2),
        GetString(SI_NVK3UT_LAM_TRACKER_HOST_ORDER_POSITION_3),
        GetString(SI_NVK3UT_LAM_TRACKER_HOST_ORDER_POSITION_4),
    }

    local function getOrderForSlot(slotIndex)
        local order = getCurrentSectionOrder()
        return order[slotIndex] or trackerOrderValues[slotIndex]
    end

    local function setOrderForSlot(slotIndex, trackerKey)
        local order = getCurrentSectionOrder()
        if order[slotIndex] == trackerKey then
            return
        end

        local currentIndex
        for index, key in ipairs(order) do
            if key == trackerKey then
                currentIndex = index
                break
            end
        end

        if currentIndex then
            table.remove(order, currentIndex)
        end

        table.insert(order, slotIndex, trackerKey)

        applySectionOrder(order)
    end

    for slotIndex = 1, #trackerOrderValues do
        controls[#controls + 1] = {
            type = "dropdown",
            name = trackerSlotLabels[slotIndex],
            choices = trackerOrderNames,
            choicesValues = trackerOrderValues,
            getFunc = function()
                return getOrderForSlot(slotIndex)
            end,
            setFunc = function(value)
                setOrderForSlot(slotIndex, value)
            end,
        }
    end

    return controls
end

local function getFeatures()
    local general = getGeneral()
    general.features = general.features or {}
    local features = general.features
    if features.hideDefaultQuestTracker == nil then
        features.hideDefaultQuestTracker = false
    end
    return features
end

local function getAppearanceSettings()
    local general = getGeneral()
    general.Appearance = general.Appearance or {}

    local appearance = general.Appearance
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

local function getLayoutSettings()
    local general = getGeneral()
    general.layout = general.layout or {}

    local layout = general.layout

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
    layout.minWidth = math.max(260, math.floor(minWidth + 0.5))

    local maxWidth = tonumber(layout.maxWidth)
    if not maxWidth then
        maxWidth = DEFAULT_LAYOUT.maxWidth
    end
    maxWidth = math.floor(maxWidth + 0.5)
    layout.maxWidth = math.max(layout.minWidth, maxWidth)

    local minHeight = tonumber(layout.minHeight)
    if not minHeight then
        minHeight = DEFAULT_LAYOUT.minHeight
    end
    layout.minHeight = math.max(240, math.floor(minHeight + 0.5))

    local maxHeight = tonumber(layout.maxHeight)
    if not maxHeight then
        maxHeight = DEFAULT_LAYOUT.maxHeight
    end
    maxHeight = math.floor(maxHeight + 0.5)
    layout.maxHeight = math.max(layout.minHeight, maxHeight)

    return layout
end

local function getWindowBarSettings()
    local general = getGeneral()
    general.WindowBars = general.WindowBars or {}

    local bars = general.WindowBars

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

local function getQuestSettings()
    local sv = getSavedVars()
    sv.QuestTracker = sv.QuestTracker or {}
    sv.QuestTracker.fonts = sv.QuestTracker.fonts or {}
    return sv.QuestTracker
end

local function getQuestFilter()
    local tracker = Nvk3UT and Nvk3UT.QuestTracker
    if tracker and tracker.EnsureQuestFilterSavedVars then
        local ok, filter = pcall(tracker.EnsureQuestFilterSavedVars)
        if ok and filter then
            return filter
        end
    end

    local sv = getSavedVars()
    sv.QuestTracker = sv.QuestTracker or {}
    local trackerSv = sv.QuestTracker
    trackerSv.questFilter = trackerSv.questFilter or {}

    local filter = trackerSv.questFilter
    local mode = tonumber(filter.mode)
    if mode ~= QUEST_FILTER_MODE_ALL and mode ~= QUEST_FILTER_MODE_ACTIVE and mode ~= QUEST_FILTER_MODE_SELECTION then
        filter.mode = QUEST_FILTER_MODE_ALL
    else
        filter.mode = mode
    end

    if type(filter.selection) ~= "table" then
        filter.selection = {}
    end

    return filter
end

local function getAchievementSettings()
    local sv = getSavedVars()
    sv.AchievementTracker = sv.AchievementTracker or {}
    sv.AchievementTracker.fonts = sv.AchievementTracker.fonts or {}
    sv.AchievementTracker.sections = sv.AchievementTracker.sections or {}
    return sv.AchievementTracker
end

local function normalizeSpacingValue(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        numeric = fallback
    end
    return math.floor(numeric + 0.5)
end

local function ensureSpacingGroup(target, defaults)
    if type(target) ~= "table" then
        target = {}
    end

    for key, defaultValue in pairs(defaults) do
        target[key] = normalizeSpacingValue(target[key], defaultValue)
    end

    return target
end

local function getTrackerSpacing(trackerKey)
    local sv = getSavedVars()
    if type(sv) ~= "table" then
        return {
            category = ensureSpacingGroup({}, DEFAULT_SPACING.category),
            entry = ensureSpacingGroup({}, DEFAULT_SPACING.entry),
            objective = ensureSpacingGroup({}, DEFAULT_SPACING.objective),
        }
    end

    sv.spacing = sv.spacing or {}
    local spacing = sv.spacing
    if type(spacing[trackerKey]) ~= "table" then
        spacing[trackerKey] = {}
    end

    local trackerSpacing = spacing[trackerKey]
    trackerSpacing.category = ensureSpacingGroup(trackerSpacing.category, DEFAULT_SPACING.category)
    trackerSpacing.entry = ensureSpacingGroup(trackerSpacing.entry, DEFAULT_SPACING.entry)
    trackerSpacing.objective = ensureSpacingGroup(trackerSpacing.objective, DEFAULT_SPACING.objective)

    return trackerSpacing
end

local ENDEAVOR_COLOR_ROLES = {
    CategoryTitle = "categoryTitle",
    EntryName = "entryTitle",
    Objective = "objectiveText",
    Active = "activeTitle",
    Completed = "completed",
}

local GOLDEN_COLOR_ROLES = {
    CategoryTitleClosed = "categoryTitleClosed",
    CategoryTitleOpen = "categoryTitleOpen",
    EntryName = "entryTitle",
    Objective = "objectiveText",
    Active = "activeTitle",
    Completed = "completed",
}

local goldenFontDefaults
local ensureGoldenFontGroup

local function getEndeavorConfig()
    local sv = getSavedVars()
    sv.Endeavor = sv.Endeavor or {}
    local config = sv.Endeavor
    config.Colors = config.Colors or {}
    config.Font = config.Font or {}
    config.Tracker = config.Tracker or {}
    config.Tracker.Fonts = config.Tracker.Fonts or {}
    return config
end

local function getGoldenConfig()
    local sv = getSavedVars()
    sv.Golden = sv.Golden or {}
    local config = sv.Golden
    config.Colors = config.Colors or {}
    config.Font = config.Font or {}
    config.Tracker = config.Tracker or {}
    config.Tracker.Fonts = config.Tracker.Fonts or {}

    local endeavorConfig = getEndeavorConfig()
    local endeavorColors = (endeavorConfig and endeavorConfig.Colors) or {}

    local function coerceColor(candidate)
        if type(candidate) ~= "table" then
            return nil
        end

        local r = candidate[1] or candidate.r or 1
        local g = candidate[2] or candidate.g or 1
        local b = candidate[3] or candidate.b or 1
        local a = candidate[4] or candidate.a or 1
        return { r, g, b, a, r = r, g = g, b = b, a = a }
    end

    local goldenColors = config.Colors
    local colorDefaults = {
        CategoryTitleClosed = { key = "CategoryTitle", role = ENDEAVOR_COLOR_ROLES.CategoryTitle },
        EntryName = { key = "EntryName", role = ENDEAVOR_COLOR_ROLES.EntryName },
        Objective = { key = "Objective", role = ENDEAVOR_COLOR_ROLES.Objective },
        Active = { key = "Active", role = ENDEAVOR_COLOR_ROLES.Active },
        Completed = { key = "Completed", role = ENDEAVOR_COLOR_ROLES.Completed },
    }

    local function applyEndeavorColorDefault(targetKey, sourceKey, sourceRole)
        if goldenColors[targetKey] ~= nil then
            return
        end

        local candidate = coerceColor(endeavorColors[sourceKey])
        if candidate == nil then
            candidate = coerceColor(getTrackerColorDefaultTable("endeavorTracker", sourceRole))
        end

        goldenColors[targetKey] = candidate
    end

    for targetKey, source in pairs(colorDefaults) do
        applyEndeavorColorDefault(targetKey, source.key, source.role)
    end

    if goldenColors.CategoryTitleOpen == nil then
        local entryColor = goldenColors.EntryName
        if entryColor == nil then
            applyEndeavorColorDefault("EntryName", "EntryName", ENDEAVOR_COLOR_ROLES.EntryName)
            entryColor = goldenColors.EntryName
        end

        goldenColors.CategoryTitleOpen = coerceColor(entryColor)
            or coerceColor(getTrackerColorDefaultTable("endeavorTracker", ENDEAVOR_COLOR_ROLES.EntryName))
    end

    local endeavorFonts = (endeavorConfig and endeavorConfig.Tracker and endeavorConfig.Tracker.Fonts) or {}

    local function copyEndeavorFontDefaults(key)
        local source = endeavorFonts[key]
        if type(source) ~= "table" then
            local altKey = type(key) == "string" and string.lower(key)
            if altKey and type(endeavorFonts[altKey]) == "table" then
                source = endeavorFonts[altKey]
            end
        end

        if type(source) ~= "table" then
            return nil
        end

        return {
            face = source.Face or source.face,
            size = source.Size or source.size,
            outline = source.Outline or source.outline,
        }
    end

    ensureGoldenFontGroup(config, "Category", function()
        return copyEndeavorFontDefaults("Category")
    end)
    ensureGoldenFontGroup(config, "Title", function()
        return copyEndeavorFontDefaults("Title")
    end)
    ensureGoldenFontGroup(config, "Objective", function()
        return copyEndeavorFontDefaults("Objective")
    end)

    return config
end

local function LamQueueFullRebuild(reason)
    local context = "lam"
    if reason ~= nil then
        local suffix = tostring(reason)
        if suffix ~= "" then
            context = string.format("lam:%s", suffix)
        end
    end

    local addon = type(Nvk3UT) == "table" and Nvk3UT or nil
    local rebuild = addon and addon.Rebuild
    if type(rebuild) ~= "table" then
        local globalRoot = type(_G) == "table" and _G.Nvk3UT_Rebuild or Nvk3UT_Rebuild
        if type(globalRoot) == "table" then
            rebuild = globalRoot
        end
    end

    if type(rebuild) ~= "table" then
        return false
    end

    local sections = rebuild.Sections or rebuild.sections
    if type(sections) == "function" then
        local ok, triggered = pcall(sections, { "trackers", "layout" }, context)
        if ok then
            if triggered == nil then
                return true
            end
            return triggered ~= false
        end
        return false
    end

    local rebuildAll = rebuild.All or rebuild.all
    if type(rebuildAll) == "function" then
        local ok, triggered = pcall(rebuildAll, context)
        if ok then
            if triggered == nil then
                return true
            end
            return triggered ~= false
        end
    end

    return false
end

local function clampEndeavorFontSize(value)
    local numeric = tonumber(value)
    if numeric == nil then
        numeric = DEFAULT_FONT_SIZE.achievement.title
    end
    numeric = math.floor(numeric + 0.5)
    if numeric < 12 then
        numeric = 12
    elseif numeric > 36 then
        numeric = 36
    end
    return numeric
end

local function getEndeavorColor(colorKey, role)
    ensureTrackerAppearance()
    local config = getEndeavorConfig()
    local color = config.Colors[colorKey]
    if type(color) == "table" then
        local r = color.r or color[1] or 1
        local g = color.g or color[2] or 1
        local b = color.b or color[3] or 1
        local a = color.a or color[4] or 1
        return r, g, b, a
    end
    return getTrackerColor("endeavorTracker", role)
end

local function setEndeavorColor(colorKey, role, r, g, b, a)
    local config = getEndeavorConfig()
    local resolvedR = r or 1
    local resolvedG = g or 1
    local resolvedB = b or 1
    local resolvedA = a or 1
    local color = config.Colors[colorKey]
    if type(color) ~= "table" then
        color = {}
        config.Colors[colorKey] = color
    end
    color[1], color[2], color[3], color[4] = resolvedR, resolvedG, resolvedB, resolvedA
    color.r, color.g, color.b, color.a = resolvedR, resolvedG, resolvedB, resolvedA
    setTrackerColor("endeavorTracker", role, resolvedR, resolvedG, resolvedB, resolvedA)
end

local function getGoldenColor(colorKey, role)
    ensureTrackerAppearance()
    local config = getGoldenConfig()
    local color = config.Colors[colorKey]
    if type(color) == "table" then
        local r = color.r or color[1] or 1
        local g = color.g or color[2] or 1
        local b = color.b or color[3] or 1
        local a = color.a or color[4] or 1
        return r, g, b, a
    end
    return getTrackerColor("goldenTracker", role)
end

local function setGoldenColor(colorKey, role, r, g, b, a)
    local config = getGoldenConfig()
    local resolvedR = r or 1
    local resolvedG = g or 1
    local resolvedB = b or 1
    local resolvedA = a or 1
    local color = config.Colors[colorKey]
    if type(color) ~= "table" then
        color = {}
        config.Colors[colorKey] = color
    end
    color[1], color[2], color[3], color[4] = resolvedR, resolvedG, resolvedB, resolvedA
    color.r, color.g, color.b, color.a = resolvedR, resolvedG, resolvedB, resolvedA
    setTrackerColor("goldenTracker", role, resolvedR, resolvedG, resolvedB, resolvedA)
end

local function refreshEndeavorModel()
    local model = Nvk3UT and Nvk3UT.EndeavorModel
    if type(model) == "table" then
        local refresh = model.RefreshFromGame or model.Refresh
        if type(refresh) == "function" then
            pcall(refresh, model)
        end
    end
end

local function refreshGoldenModel()
    local model = Nvk3UT and Nvk3UT.GoldenModel
    if type(model) == "table" then
        local refresh = model.RefreshFromGame or model.Refresh
        if type(refresh) == "function" then
            pcall(refresh, model)
        end
    end
end

local function markEndeavorDirty(reason)
    local controller = Nvk3UT and Nvk3UT.EndeavorTrackerController
    if type(controller) == "table" then
        local markDirty = controller.MarkDirty or controller.RequestRefresh
        if type(markDirty) == "function" then
            pcall(markDirty, controller, reason)
        end
    end
end

local function markGoldenDirty(reason)
    local controller = Nvk3UT and Nvk3UT.GoldenTrackerController
    if type(controller) == "table" then
        local markDirty = controller.MarkDirty or controller.RequestRefresh
        if type(markDirty) == "function" then
            pcall(markDirty, controller, reason)
        end
    end
end

local function queueEndeavorDirty()
    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if type(runtime) == "table" then
        local queueDirty = runtime.QueueDirty or runtime.MarkDirty or runtime.RequestRefresh
        if type(queueDirty) == "function" then
            pcall(queueDirty, runtime, "endeavor")
        end
    end
end

local function queueLayoutDirty()
    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if type(runtime) == "table" then
        local queueDirty = runtime.QueueDirty or runtime.QueueLayout
        if type(queueDirty) == "function" then
            pcall(queueDirty, runtime, "layout")
        end
    end
end

local function queueSpacingFullRebuild()
    local rebuild = (Nvk3UT and Nvk3UT.Rebuild) or Nvk3UT_Rebuild
    if type(rebuild) == "table" then
        local schedule = rebuild.ScheduleSpacingRebuild or rebuild.ScheduleToggleFollowup or rebuild.All
        if type(schedule) == "function" then
            pcall(schedule, "spacing")
        end
    end
end

local function queueGoldenDirty()
    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if type(runtime) == "table" then
        local queueDirty = runtime.QueueDirty or runtime.MarkDirty or runtime.RequestRefresh
        if type(queueDirty) == "function" then
            pcall(queueDirty, runtime, "golden")
        end
    end
end

local DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR = { r = 1, g = 1, b = 0.6, a = 1 }

local function ensureTrackerAppearance()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and host.EnsureAppearanceDefaults then
        host.EnsureAppearanceDefaults()
    end
end

local function getTrackerColor(trackerType, role)
    ensureTrackerAppearance()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and host.GetTrackerColor then
        return host.GetTrackerColor(trackerType, role)
    end
    if host and host.GetDefaultTrackerColor then
        return host.GetDefaultTrackerColor(trackerType, role)
    end
    return 1, 1, 1, 1
end

local function getDefaultTrackerColor(trackerType, role)
    ensureTrackerAppearance()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and host.GetDefaultTrackerColor then
        return host.GetDefaultTrackerColor(trackerType, role)
    end
    return getTrackerColor(trackerType, role)
end

local function getTrackerColorDefaultTable(trackerType, role)
    local r, g, b, a = getDefaultTrackerColor(trackerType, role)
    return { r = r, g = g, b = b, a = a }
end

local function setTrackerColor(trackerType, role, r, g, b, a)
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and host.SetTrackerColor then
        host.SetTrackerColor(trackerType, role, r, g, b, a)
        ensureTrackerAppearance()
        return
    end

    local sv = getSavedVars()
    if not sv then
        return
    end

    sv.appearance = sv.appearance or {}
    sv.appearance[trackerType] = sv.appearance[trackerType] or {}
    local tracker = sv.appearance[trackerType]
    tracker.colors = tracker.colors or {}
    tracker.colors[role] = {
        r = r or 1,
        g = g or 1,
        b = b or 1,
        a = a or 1,
    }
end

local function getMouseoverHighlightColor(trackerType)
    ensureTrackerAppearance()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and host.GetMouseoverHighlightColor then
        return host.GetMouseoverHighlightColor(trackerType)
    end

    local color = DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR
    return color.r, color.g, color.b, color.a
end

local function getMouseoverHighlightDefaultTable(trackerType)
    ensureTrackerAppearance()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and host.GetDefaultMouseoverHighlightColor then
        local r, g, b, a = host.GetDefaultMouseoverHighlightColor(trackerType)
        return { r = r, g = g, b = b, a = a }
    end

    local color = DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR
    return { r = color.r, g = color.g, b = color.b, a = color.a }
end

local function setMouseoverHighlightColor(trackerType, r, g, b, a)
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and host.SetMouseoverHighlightColor then
        host.SetMouseoverHighlightColor(trackerType, r, g, b, a)
        ensureTrackerAppearance()
        return
    end

    local sv = getSavedVars()
    if not sv then
        return
    end

    sv.appearance = sv.appearance or {}
    sv.appearance[trackerType] = sv.appearance[trackerType] or {}
    local tracker = sv.appearance[trackerType]
    tracker.mouseoverHighlightColor = {
        r = r or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR.r,
        g = g or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR.g,
        b = b or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR.b,
        a = a or DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR.a,
    }
end

local function ensureFont(settings, key, defaults)
    settings.fonts[key] = settings.fonts[key] or {}
    local font = settings.fonts[key]
    font.face = font.face or defaults.face or FONT_FACE_CHOICES[1].face
    font.size = font.size or defaults.size or 16
    font.outline = font.outline or defaults.outline or "soft-shadow-thick"
    return font
end

local function applyQuestSettings()
    if Nvk3UT and Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.ApplySettings then
        Nvk3UT.QuestTracker.ApplySettings(getQuestSettings())
    end
end

local function applyQuestTheme()
    if Nvk3UT and Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.ApplyTheme then
        Nvk3UT.QuestTracker.ApplyTheme(getQuestSettings())
    end
end

local function refreshQuestTracker()
    local controller = Nvk3UT and Nvk3UT.QuestTrackerController
    if controller and controller.RequestRefresh then
        controller:RequestRefresh("LAM:refreshQuestTracker")
        return
    end

    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if runtime and runtime.QueueDirty then
        runtime:QueueDirty("quest")
    elseif Nvk3UT and Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.RequestRefresh then
        Nvk3UT.QuestTracker.RequestRefresh()
    end
end

local function applyAchievementSettings()
    if Nvk3UT and Nvk3UT.AchievementTracker and Nvk3UT.AchievementTracker.ApplySettings then
        Nvk3UT.AchievementTracker.ApplySettings(getAchievementSettings())
    end
end

local function applyAchievementTheme()
    if Nvk3UT and Nvk3UT.AchievementTracker and Nvk3UT.AchievementTracker.ApplyTheme then
        Nvk3UT.AchievementTracker.ApplyTheme(getAchievementSettings())
    end
end

local function applyHostAppearance()
    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplyAppearance then
        Nvk3UT.TrackerHost.ApplyAppearance()
    end
end

local function refreshAchievementTracker()
    local controller = Nvk3UT and Nvk3UT.AchievementTrackerController
    if controller and controller.MarkDirty then
        controller.MarkDirty()
        return
    end

    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if runtime and runtime.QueueDirty then
        runtime:QueueDirty("achievement")
        return
    end

    if Nvk3UT and Nvk3UT.AchievementTracker and Nvk3UT.AchievementTracker.Refresh then
        Nvk3UT.AchievementTracker:Refresh()
    end
end

local function updateStatus()
    if Nvk3UT and Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then
        Nvk3UT.UI.UpdateStatus()
    end
end

local function applyFeatureToggles()
    if Nvk3UT and Nvk3UT.UI and Nvk3UT.UI.ApplyFeatureToggles then
        Nvk3UT.UI.ApplyFeatureToggles()
    end
end

local function updateTooltips(enabled)
    if Nvk3UT and Nvk3UT.Tooltips and Nvk3UT.Tooltips.Enable then
        Nvk3UT.Tooltips.Enable(enabled ~= false)
    end
end

local function questFontDefaults(key)
    local defaults = DEFAULT_FONT_SIZE.quest
    local face = FONT_FACE_CHOICES[1].face
    local outline = "soft-shadow-thick"
    local size = defaults[key] or 16
    return { face = face, size = size, outline = outline }
end

local function achievementFontDefaults(key)
    local defaults = DEFAULT_FONT_SIZE.achievement
    local face = FONT_FACE_CHOICES[1].face
    local outline = "soft-shadow-thick"
    local size = defaults[key] or 16
    return { face = face, size = size, outline = outline }
end

local function endeavorFontDefaults(key)
    local defaults = DEFAULT_FONT_SIZE.achievement
    local normalized = type(key) == "string" and string.lower(key) or ""
    local size = defaults.title
    if normalized == "category" then
        size = defaults.category
    elseif normalized == "objective" then
        size = defaults.line
    end
    return {
        Face = FONT_FACE_CHOICES[1].face,
        Size = size,
        Outline = "soft-shadow-thick",
    }
end

function goldenFontDefaults(key)
    local endeavorDefaults = endeavorFontDefaults(key)
    if not endeavorDefaults then
        return { face = FONT_FACE_CHOICES[1].face, size = 16, outline = "soft-shadow-thick" }
    end

    return {
        face = endeavorDefaults.Face or endeavorDefaults.face,
        size = endeavorDefaults.Size or endeavorDefaults.size,
        outline = endeavorDefaults.Outline or endeavorDefaults.outline,
    }
end

function ensureGoldenFontGroup(config, key, defaults)
    local defaultsValue = defaults
    if type(defaultsValue) == "function" then
        defaultsValue = defaults()
    end
    if defaultsValue == nil then
        defaultsValue = goldenFontDefaults(key)
    end

    if type(config) ~= "table" then
        return defaultsValue
    end

    config.Tracker = config.Tracker or {}
    local tracker = config.Tracker
    tracker.Fonts = tracker.Fonts or {}
    local fonts = tracker.Fonts

    local group = fonts[key]
    if type(group) ~= "table" then
        group = {}
        fonts[key] = group
    end

    if type(group.face) ~= "string" or group.face == "" then
        group.face = group.Face
    end
    if group.size == nil then
        group.size = group.Size
    end
    if type(group.outline) ~= "string" or group.outline == "" then
        group.outline = group.Outline
    end

    local defaultsFace = defaultsValue and (defaultsValue.face or defaultsValue.Face)
    local defaultsSize = defaultsValue and (defaultsValue.size or defaultsValue.Size)
    local defaultsOutline = defaultsValue and (defaultsValue.outline or defaultsValue.Outline)

    group.face = group.face or defaultsFace
    group.size = group.size or defaultsSize
    group.outline = group.outline or defaultsOutline

    group.Face = group.Face or group.face
    group.Size = group.Size or group.size
    group.Outline = group.Outline or group.outline

    return group
end

local function ensureEndeavorFontGroup(config, key, defaults)
    local defaultsValue = defaults
    if type(defaultsValue) == "function" then
        defaultsValue = defaults()
    end
    if defaultsValue == nil then
        defaultsValue = endeavorFontDefaults(key)
    end

    if type(config) ~= "table" then
        return defaultsValue
    end

    config.Tracker = config.Tracker or {}
    local tracker = config.Tracker
    tracker.Fonts = tracker.Fonts or {}
    local fonts = tracker.Fonts

    local group = fonts[key]
    if type(group) ~= "table" then
        local altKey = type(key) == "string" and string.lower(key) or nil
        if altKey and type(fonts[altKey]) == "table" then
            group = fonts[altKey]
        else
            group = {}
        end
        fonts[key] = group
    else
        fonts[key] = group
    end

    if type(group.face) == "string" and (group.Face == nil or group.Face == "") then
        group.Face = group.face
    end
    if group.size ~= nil and (group.Size == nil or group.Size == 0) then
        group.Size = group.size
    end
    if type(group.outline) == "string" and (group.Outline == nil or group.Outline == "") then
        group.Outline = group.outline
    end

    if type(group.Face) ~= "string" or group.Face == "" then
        group.Face = defaultsValue.Face or FONT_FACE_CHOICES[1].face
    end

    group.Size = clampEndeavorFontSize(group.Size or defaultsValue.Size)

    if type(group.Outline) ~= "string" or group.Outline == "" then
        group.Outline = defaultsValue.Outline or OUTLINE_CHOICES[3].value
    end

    return group
end

local function buildFontControls(label, settings, key, defaults, onChanged, adapter)
    adapter = adapter or {}
    local ensureTarget = adapter.ensureFont or ensureFont
    local clampSize = adapter.clampSize or function(value)
        local numeric = tonumber(value)
        if numeric == nil then
            return 16
        end
        return math.floor(numeric + 0.5)
    end
    local getFace = adapter.getFace or function(font)
        return font.face
    end
    local setFace = adapter.setFace or function(font, value)
        font.face = value
    end
    local getSize = adapter.getSize or function(font)
        return font.size
    end
    local setSize = adapter.setSize or function(font, value)
        font.size = value
    end
    local getOutline = adapter.getOutline or function(font)
        return font.outline
    end
    local setOutline = adapter.setOutline or function(font, value)
        font.outline = value
    end

    local defaultsFactory
    if type(defaults) == "function" then
        defaultsFactory = defaults
    else
        defaultsFactory = function()
            return defaults
        end
    end

    local function ensureFontInstance()
        return ensureTarget(settings, key, defaultsFactory())
    end

    local function triggerChanged()
        if type(onChanged) == "function" then
            onChanged()
        end
    end

    return {
        {
            type = "dropdown",
            name = string.format(GetString(SI_NVK3UT_LAM_FONT_FACE_FORMAT), label),
            choices = FONT_FACE_NAMES,
            choicesValues = FONT_FACE_VALUES,
            getFunc = function()
                local font = ensureFontInstance()
                return getFace(font)
            end,
            setFunc = function(value)
                local font = ensureFontInstance()
                setFace(font, value)
                triggerChanged()
            end,
        },
        {
            type = "slider",
            name = string.format(GetString(SI_NVK3UT_LAM_FONT_SIZE_FORMAT), label),
            min = 12,
            max = 36,
            step = 1,
            getFunc = function()
                local font = ensureFontInstance()
                return getSize(font)
            end,
            setFunc = function(value)
                local font = ensureFontInstance()
                setSize(font, clampSize(value))
                triggerChanged()
            end,
        },
        {
            type = "dropdown",
            name = string.format(GetString(SI_NVK3UT_LAM_FONT_OUTLINE_FORMAT), label),
            choices = (function()
                local names = {}
                for index = 1, #OUTLINE_CHOICES do
                    local stringId = OUTLINE_CHOICES[index].name
                    local localizedName = stringId and GetString(stringId)
                    if localizedName == nil or localizedName == "" then
                        localizedName = tostring(stringId)
                    end

                    names[index] = localizedName
                end
                return names
            end)(),
            choicesValues = (function()
                local values = {}
                for index = 1, #OUTLINE_CHOICES do
                    values[index] = OUTLINE_CHOICES[index].value
                end
                return values
            end)(),
            getFunc = function()
                local font = ensureFontInstance()
                return getOutline(font)
            end,
            setFunc = function(value)
                local font = ensureFontInstance()
                setOutline(font, value)
                triggerChanged()
            end,
        },
    }
end

local function buildSpacingControls(trackerKey)
    local controls = {}
    local function notifySpacingChanged()
        if trackerKey == "quest" then
            applyQuestSettings()
        elseif trackerKey == "achievement" then
            refreshAchievementTracker()
            return
        elseif trackerKey == "endeavor" then
            markEndeavorDirty("spacing")
            queueEndeavorDirty()
            queueLayoutDirty()
        elseif trackerKey == "golden" then
            markGoldenDirty("spacing")
            queueGoldenDirty()
        end
        queueSpacingFullRebuild()
    end

    local function setSpacingValue(groupKey, fieldKey, value)
        local spacing = getTrackerSpacing(trackerKey)
        local group = spacing[groupKey]
        if type(group) ~= "table" then
            group = {}
            spacing[groupKey] = group
        end
        group[fieldKey] = normalizeSpacingValue(value, DEFAULT_SPACING[groupKey][fieldKey])
        notifySpacingChanged()
    end

    local function getSpacingValue(groupKey, fieldKey)
        local spacing = getTrackerSpacing(trackerKey)
        local group = spacing[groupKey]
        if type(group) ~= "table" then
            return DEFAULT_SPACING[groupKey][fieldKey]
        end
        return normalizeSpacingValue(group[fieldKey], DEFAULT_SPACING[groupKey][fieldKey])
    end

    controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_SPACING_GROUP_CATEGORY) }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_CATEGORY_INDENT),
        min = 0,
        max = 200,
        step = 1,
        getFunc = function()
            return getSpacingValue("category", "indent")
        end,
        setFunc = function(value)
            setSpacingValue("category", "indent", value)
        end,
        default = DEFAULT_SPACING.category.indent,
    }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_CATEGORY_ABOVE),
        min = 0,
        max = 50,
        step = 1,
        getFunc = function()
            return getSpacingValue("category", "spacingAbove")
        end,
        setFunc = function(value)
            setSpacingValue("category", "spacingAbove", value)
        end,
        default = DEFAULT_SPACING.category.spacingAbove,
    }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_CATEGORY_BELOW),
        min = 0,
        max = 50,
        step = 1,
        getFunc = function()
            return getSpacingValue("category", "spacingBelow")
        end,
        setFunc = function(value)
            setSpacingValue("category", "spacingBelow", value)
        end,
        default = DEFAULT_SPACING.category.spacingBelow,
    }

    controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_SPACING_GROUP_ENTRY) }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_ENTRY_INDENT),
        min = 0,
        max = 200,
        step = 1,
        getFunc = function()
            return getSpacingValue("entry", "indent")
        end,
        setFunc = function(value)
            setSpacingValue("entry", "indent", value)
        end,
        default = DEFAULT_SPACING.entry.indent,
    }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_ENTRY_ABOVE),
        min = 0,
        max = 50,
        step = 1,
        getFunc = function()
            return getSpacingValue("entry", "spacingAbove")
        end,
        setFunc = function(value)
            setSpacingValue("entry", "spacingAbove", value)
        end,
        default = DEFAULT_SPACING.entry.spacingAbove,
    }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_ENTRY_BELOW),
        min = 0,
        max = 50,
        step = 1,
        getFunc = function()
            return getSpacingValue("entry", "spacingBelow")
        end,
        setFunc = function(value)
            setSpacingValue("entry", "spacingBelow", value)
        end,
        default = DEFAULT_SPACING.entry.spacingBelow,
    }

    controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_SPACING_GROUP_OBJECTIVE) }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_OBJECTIVE_INDENT),
        min = 0,
        max = 200,
        step = 1,
        getFunc = function()
            return getSpacingValue("objective", "indent")
        end,
        setFunc = function(value)
            setSpacingValue("objective", "indent", value)
        end,
        default = DEFAULT_SPACING.objective.indent,
    }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_OBJECTIVE_ABOVE),
        min = 0,
        max = 50,
        step = 1,
        getFunc = function()
            return getSpacingValue("objective", "spacingAbove")
        end,
        setFunc = function(value)
            setSpacingValue("objective", "spacingAbove", value)
        end,
        default = DEFAULT_SPACING.objective.spacingAbove,
    }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_OBJECTIVE_BELOW),
        min = 0,
        max = 50,
        step = 1,
        getFunc = function()
            return getSpacingValue("objective", "spacingBelow")
        end,
        setFunc = function(value)
            setSpacingValue("objective", "spacingBelow", value)
        end,
        default = DEFAULT_SPACING.objective.spacingBelow,
    }
    controls[#controls + 1] = {
        type = "slider",
        name = GetString(SI_NVK3UT_LAM_SPACING_OBJECTIVE_BETWEEN),
        min = 0,
        max = 50,
        step = 1,
        getFunc = function()
            return getSpacingValue("objective", "spacingBetween")
        end,
        setFunc = function(value)
            setSpacingValue("objective", "spacingBetween", value)
        end,
        default = DEFAULT_SPACING.objective.spacingBetween,
    }

    return controls
end

function acquireLam()
    if LibAddonMenu2 then
        return LibAddonMenu2
    end

    if LibStub then
        return LibStub("LibAddonMenu-2.0", true)
    end

    return nil
end

local function registerLamCallbacks(LAM, panelName, panel)
    if not (CALLBACK_MANAGER and LAM and panelName) then
        return
    end

    if L._lamCallbacksRegistered then
        return
    end

    L._lamCallbacksRegistered = true
    L._panelName = panelName
    L._panelDefinition = panel

    local function matchesPanel(control)
        if not control then
            return false
        end

        if L._panelControl and control == L._panelControl then
            return true
        end

        if control.GetName then
            local name = control:GetName()
            if name and name == L._panelName then
                L._panelControl = control
                return true
            end
        end

        local expected = L._panelName and _G[L._panelName]
        if expected and control == expected then
            L._panelControl = expected
            return true
        end

        if control.data and L._panelDefinition and control.data == L._panelDefinition then
            L._panelControl = control
            return true
        end

        return false
    end

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(control)
        if not matchesPanel(control) then
            return
        end

        if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.OnLamPanelOpened then
            pcall(Nvk3UT.TrackerHost.OnLamPanelOpened, control)
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(control)
        if not matchesPanel(control) then
            return
        end

        if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.OnLamPanelClosed then
            pcall(Nvk3UT.TrackerHost.OnLamPanelClosed, control)
        end
    end)
end

local function registerPanel(displayTitle)
    local LAM = acquireLam()
    if not LAM then
        return false
    end

    if L._registered then
        return true
    end

    local panelName = "Nvk3UT_Panel"

    local panel = {
        type = "panel",
        name = displayTitle or DEFAULT_PANEL_TITLE,
        displayName = "|c66CCFF" .. (displayTitle or DEFAULT_PANEL_TITLE) .. "|r",
        author = "Nvk3",
        version = getAddonVersionString() or "Unknown",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    local options = {}
    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_SECTION_JOURNAL),
        controls = (function()
            local controls = {}

            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_JOURNAL_HEADER_STORAGE) }

            controls[#controls + 1] = {
                type = "dropdown",
                name = GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_FAVORITE_SCOPE),
                choices = {
                    GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_SCOPE_ACCOUNT),
                    GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_SCOPE_CHARACTER),
                },
                choicesValues = { "account", "character" },
                getFunc = function()
                    local general = getGeneral()
                    return general.favScope or "account"
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    local old = general.favScope or "account"
                    general.favScope = value or "account"
                    if Nvk3UT.FavoritesData and Nvk3UT.FavoritesData.MigrateScope then
                        Nvk3UT.FavoritesData.MigrateScope(old, general.favScope)
                    end
                    if Nvk3UT.AchievementModel and Nvk3UT.AchievementModel.OnFavoritesChanged then
                        Nvk3UT.AchievementModel.OnFavoritesChanged()
                    end
                    local cache = Nvk3UT and Nvk3UT.AchievementCache
                    if cache and cache.OnOptionsChanged then
                        cache.OnOptionsChanged({ key = "favorites" })
                    end
                    updateStatus()
                end,
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_FAVORITE_SCOPE_DESC),
                default = "account",
            }

            controls[#controls + 1] = {
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_RECENT_LIMIT),
                min = 25,
                max = 200,
                step = 5,
                getFunc = function()
                    local general = getGeneral()
                    return general.recentMax or 100
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    general.recentMax = value or 100
                    local cache = Nvk3UT and Nvk3UT.AchievementCache
                    if cache and cache.OnOptionsChanged then
                        cache.OnOptionsChanged({ key = "recentMax" })
                    end
                    updateStatus()
                end,
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_RECENT_LIMIT_DESC),
            }

            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_JOURNAL_HEADER_FEATURES) }

            local featureControls = {
                { key = "completed", label = GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_FEATURE_COMPLETED) },
                { key = "favorites", label = GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_FEATURE_FAVORITES) },
                { key = "recent", label = GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_FEATURE_RECENT) },
                { key = "todo", label = GetString(SI_NVK3UT_LAM_OPTION_JOURNAL_FEATURE_TODO) },
            }

            for index = 1, #featureControls do
                local entry = featureControls[index]
                controls[#controls + 1] = {
                    type = "checkbox",
                    name = entry.label,
                    getFunc = function()
                        local features = getFeatures()
                        return features[entry.key] ~= false
                    end,
                    setFunc = function(value)
                        local features = getFeatures()
                        features[entry.key] = value
                        applyFeatureToggles()
                        local cache = Nvk3UT and Nvk3UT.AchievementCache
                        if cache and cache.OnOptionsChanged then
                            cache.OnOptionsChanged({ key = entry.key })
                        end
                    end,
                    default = true,
                }
            end

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_ACHIEVEMENT_TOOLTIPS),
                tooltip = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_ACHIEVEMENT_TOOLTIPS_DESC),
                getFunc = function()
                    local general = getGeneral()
                    return general.features.tooltips ~= false
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    general.features.tooltips = value
                    updateTooltips(value)
                end,
                default = true,
            }

            return controls
        end)(),
    }

    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_SECTION_STATUS_TEXT),
        controls = (function()
            local controls = {}

            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_STATUS_HEADER_DISPLAY) }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_STATUS_SHOW_COMPASS),
                getFunc = function()
                    local general = getGeneral()
                    return general.showStatus ~= false
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    general.showStatus = value
                    updateStatus()
                end,
                default = false,
            }

            return controls
        end)(),
    }

    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_SECTION_TRACKER_HOST),
        controls = (function()
            local controls = {}

            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_TRACKER_HOST_HEADER_WINDOW) }

            local function addControl(control)
                controls[#controls + 1] = control
            end

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_SHOW),
                getFunc = function()
                    local general = getGeneral()
                    return general.window.visible ~= false
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    general.window.visible = value ~= false

                    local addon = Nvk3UT
                    local host = addon and addon.TrackerHost
                    if host then
                        if type(host.SetVisible) == "function" then
                            pcall(host.SetVisible, value)
                        elseif type(host.ApplySettings) == "function" then
                            pcall(host.ApplySettings)
                        end
                    end
                end,
                default = true,
            })

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_LOCK),
                getFunc = function()
                    local general = getGeneral()
                    return general.window.locked == true
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    general.window.locked = value and true or false
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                default = DEFAULT_WINDOW.locked,
            })

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_ON_TOP),
                getFunc = function()
                    local general = getGeneral()
                    return general.window.onTop == true
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    general.window.onTop = value == true
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                default = DEFAULT_WINDOW.onTop,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_WIDTH),
                min = 260,
                max = 1200,
                step = 10,
                getFunc = function()
                    local general = getGeneral()
                    return math.floor((general.window.width or DEFAULT_WINDOW.width) + 0.5)
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    local layout = getLayoutSettings()
                    local numeric = math.floor((tonumber(value) or general.window.width or DEFAULT_WINDOW.width) + 0.5)
                    numeric = clamp(numeric, layout.minWidth or 260, layout.maxWidth or 1200)
                    general.window.width = numeric
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                disabled = function()
                    return getLayoutSettings().autoGrowH == true
                end,
                default = DEFAULT_WINDOW.width,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_HEIGHT),
                min = 240,
                max = 1200,
                step = 10,
                getFunc = function()
                    local general = getGeneral()
                    return math.floor((general.window.height or DEFAULT_WINDOW.height) + 0.5)
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    local layout = getLayoutSettings()
                    local numeric = math.floor((tonumber(value) or general.window.height or DEFAULT_WINDOW.height) + 0.5)
                    numeric = clamp(numeric, layout.minHeight or 240, layout.maxHeight or 1200)
                    general.window.height = numeric
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                disabled = function()
                    return getLayoutSettings().autoGrowV == true
                end,
                default = DEFAULT_WINDOW.height,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_HEADER_HEIGHT),
                min = 0,
                max = MAX_BAR_HEIGHT,
                step = 1,
                getFunc = function()
                    local bars = getWindowBarSettings()
                    return bars.headerHeightPx or DEFAULT_WINDOW_BARS.headerHeightPx
                end,
                setFunc = function(value)
                    local bars = getWindowBarSettings()
                    local numeric = math.max(0, math.min(MAX_BAR_HEIGHT, math.floor((tonumber(value) or 0) + 0.5)))
                    bars.headerHeightPx = numeric
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplyWindowBars then
                        Nvk3UT.TrackerHost.ApplyWindowBars()
                    end
                end,
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_HEADER_HEIGHT_DESC),
                default = DEFAULT_WINDOW_BARS.headerHeightPx,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_FOOTER_HEIGHT),
                min = 0,
                max = MAX_BAR_HEIGHT,
                step = 1,
                getFunc = function()
                    local bars = getWindowBarSettings()
                    return bars.footerHeightPx or DEFAULT_WINDOW_BARS.footerHeightPx
                end,
                setFunc = function(value)
                    local bars = getWindowBarSettings()
                    local numeric = math.max(0, math.min(MAX_BAR_HEIGHT, math.floor((tonumber(value) or 0) + 0.5)))
                    bars.footerHeightPx = numeric
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplyWindowBars then
                        Nvk3UT.TrackerHost.ApplyWindowBars()
                    end
                end,
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_FOOTER_HEIGHT_DESC),
                default = DEFAULT_WINDOW_BARS.footerHeightPx,
            })

            addControl({
                type = "button",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_RESET_POSITION),
                func = function()
                    local general = getGeneral()
                    general.window.left = DEFAULT_WINDOW.left
                    general.window.top = DEFAULT_WINDOW.top
                    general.window.width = DEFAULT_WINDOW.width
                    general.window.height = DEFAULT_WINDOW.height
                    general.window.visible = DEFAULT_WINDOW.visible
                    general.window.clamp = DEFAULT_WINDOW.clamp
                    general.window.onTop = DEFAULT_WINDOW.onTop
                    general.window.locked = DEFAULT_WINDOW.locked
                    general.WindowBars = general.WindowBars or {}
                    general.WindowBars.headerHeightPx = DEFAULT_WINDOW_BARS.headerHeightPx
                    general.WindowBars.footerHeightPx = DEFAULT_WINDOW_BARS.footerHeightPx
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    elseif Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplyWindowBars then
                        Nvk3UT.TrackerHost.ApplyWindowBars()
                    end
                end,
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_RESET_POSITION_DESC),
            })

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_BACKGROUND),
                getFunc = function()
                    local appearance = getAppearanceSettings()
                    return appearance.enabled ~= false
                end,
                setFunc = function(value)
                    local appearance = getAppearanceSettings()
                    appearance.enabled = value ~= false
                    applyHostAppearance()
                end,
                default = true,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_BACKGROUND_ALPHA),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function()
                    local appearance = getAppearanceSettings()
                    return math.floor((appearance.alpha or 0) * 100 + 0.5)
                end,
                setFunc = function(value)
                    local appearance = getAppearanceSettings()
                    appearance.alpha = clamp((tonumber(value) or 0) / 100, 0, 1)
                    applyHostAppearance()
                end,
                disabled = function()
                    return getAppearanceSettings().enabled == false
                end,
                default = math.floor(DEFAULT_APPEARANCE.alpha * 100 + 0.5),
            })

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_EDGE),
                getFunc = function()
                    local appearance = getAppearanceSettings()
                    return appearance.edgeEnabled ~= false
                end,
                setFunc = function(value)
                    local appearance = getAppearanceSettings()
                    appearance.edgeEnabled = value ~= false
                    applyHostAppearance()
                end,
                default = true,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_EDGE_ALPHA),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function()
                    local appearance = getAppearanceSettings()
                    return math.floor((appearance.edgeAlpha or 0) * 100 + 0.5)
                end,
                setFunc = function(value)
                    local appearance = getAppearanceSettings()
                    appearance.edgeAlpha = clamp((tonumber(value) or 0) / 100, 0, 1)
                    applyHostAppearance()
                end,
                disabled = function()
                    local appearance = getAppearanceSettings()
                    return appearance.edgeEnabled == false
                end,
                default = math.floor(DEFAULT_APPEARANCE.edgeAlpha * 100 + 0.5),
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_EDGE_THICKNESS),
                min = 1,
                max = 12,
                step = 1,
                getFunc = function()
                    local appearance = getAppearanceSettings()
                    return appearance.edgeThickness or DEFAULT_APPEARANCE.edgeThickness
                end,
                setFunc = function(value)
                    local appearance = getAppearanceSettings()
                    local numeric = math.max(1, math.floor((tonumber(value) or appearance.edgeThickness or 1) + 0.5))
                    appearance.edgeThickness = numeric
                    applyHostAppearance()
                end,
                disabled = function()
                    return getAppearanceSettings().edgeEnabled == false
                end,
                default = DEFAULT_APPEARANCE.edgeThickness,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_PADDING),
                min = 0,
                max = 48,
                step = 1,
                getFunc = function()
                    local appearance = getAppearanceSettings()
                    return appearance.padding or 0
                end,
                setFunc = function(value)
                    local appearance = getAppearanceSettings()
                    appearance.padding = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
                    applyHostAppearance()
                end,
                default = DEFAULT_APPEARANCE.padding,
            })

            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_TRACKER_HOST_HEADER_LAYOUT) }

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_AUTOGROW_V),
                getFunc = function()
                    local layout = getLayoutSettings()
                    return layout.autoGrowV == true
                end,
                setFunc = function(value)
                    local layout = getLayoutSettings()
                    layout.autoGrowV = value == true
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                default = DEFAULT_LAYOUT.autoGrowV,
            })

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_AUTOGROW_H),
                getFunc = function()
                    local layout = getLayoutSettings()
                    return layout.autoGrowH == true
                end,
                setFunc = function(value)
                    local layout = getLayoutSettings()
                    layout.autoGrowH = value == true
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                default = DEFAULT_LAYOUT.autoGrowH,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_MIN_WIDTH),
                min = 260,
                max = 800,
                step = 10,
                getFunc = function()
                    return getLayoutSettings().minWidth
                end,
                setFunc = function(value)
                    local layout = getLayoutSettings()
                    local numeric = math.floor((tonumber(value) or layout.minWidth) + 0.5)
                    numeric = math.max(260, math.min(numeric, layout.maxWidth))
                    layout.minWidth = numeric
                    if layout.maxWidth < layout.minWidth then
                        layout.maxWidth = layout.minWidth
                    end
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                default = DEFAULT_LAYOUT.minWidth,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_MAX_WIDTH),
                min = 260,
                max = 1200,
                step = 10,
                getFunc = function()
                    return getLayoutSettings().maxWidth
                end,
                setFunc = function(value)
                    local layout = getLayoutSettings()
                    local numeric = math.floor((tonumber(value) or layout.maxWidth) + 0.5)
                    numeric = math.max(layout.minWidth, math.min(numeric, 1200))
                    layout.maxWidth = numeric
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                default = DEFAULT_LAYOUT.maxWidth,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_MIN_HEIGHT),
                min = 240,
                max = 800,
                step = 10,
                getFunc = function()
                    return getLayoutSettings().minHeight
                end,
                setFunc = function(value)
                    local layout = getLayoutSettings()
                    local numeric = math.floor((tonumber(value) or layout.minHeight) + 0.5)
                    numeric = math.max(240, math.min(numeric, layout.maxHeight))
                    layout.minHeight = numeric
                    if layout.maxHeight < layout.minHeight then
                        layout.maxHeight = layout.minHeight
                    end
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                default = DEFAULT_LAYOUT.minHeight,
            })

            addControl({
                type = "slider",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_MAX_HEIGHT),
                min = 240,
                max = 1200,
                step = 10,
                getFunc = function()
                    return getLayoutSettings().maxHeight
                end,
                setFunc = function(value)
                    local layout = getLayoutSettings()
                    local numeric = math.floor((tonumber(value) or layout.maxHeight) + 0.5)
                    numeric = math.max(layout.minHeight, math.min(numeric, 1200))
                    layout.maxHeight = numeric
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplySettings then
                        Nvk3UT.TrackerHost.ApplySettings()
                    end
                end,
                default = DEFAULT_LAYOUT.maxHeight,
            })

            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_TRACKER_HOST_HEADER_BEHAVIOR) }

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_HIDE_IN_COMBAT),
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_HIDE_IN_COMBAT_DESC),
                getFunc = function()
                    local settings = getHostSettings()
                    return settings.HideInCombat == true
                end,
                setFunc = function(value)
                    local settings = getHostSettings()
                    settings.HideInCombat = value == true
                    local host = Nvk3UT and Nvk3UT.TrackerHost
                    if host and host.ApplyVisibilityRules then
                        host:ApplyVisibilityRules()
                    end
                end,
                default = DEFAULT_HOST_SETTINGS.HideInCombat,
            })

            addControl({
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CORNER_BUTTON),
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CORNER_BUTTON_DESC),
                getFunc = function()
                    local settings = getHostSettings()
                    return settings.CornerButtonEnabled ~= false
                end,
                setFunc = function(value)
                    local settings = getHostSettings()
                    settings.CornerButtonEnabled = value ~= false

                    local host = Nvk3UT and Nvk3UT.TrackerHost
                    if host and host.SetCornerButtonEnabled then
                        host:SetCornerButtonEnabled(settings.CornerButtonEnabled)
                    end
                end,
                default = DEFAULT_HOST_SETTINGS.CornerButtonEnabled,
            })

            addControl({
                type = "dropdown",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CORNER_POSITION),
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CORNER_POSITION_DESC),
                choices = CORNER_POSITION_CHOICES,
                choicesValues = CORNER_POSITION_VALUES,
                getFunc = function()
                    local settings = getHostSettings()
                    return settings.CornerPosition
                end,
                setFunc = function(value)
                    local settings = getHostSettings()
                    settings.CornerPosition = normalizeCornerPosition(value)

                    local host = Nvk3UT and Nvk3UT.TrackerHost
                    if host and host.SetCornerPosition then
                        host.SetCornerPosition(settings.CornerPosition)
                    end
                end,
                disabled = function()
                    local settings = getHostSettings()
                    return settings.CornerButtonEnabled == false
                end,
                default = DEFAULT_HOST_SETTINGS.CornerPosition,
            })

            addControl({
                type = "dropdown",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CONTENT_ALIGN),
                choices = {
                    GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CONTENT_ALIGN_LEFT),
                    GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_CONTENT_ALIGN_RIGHT),
                },
                choicesValues = { "left", "right" },
                getFunc = function()
                    local settings = getHostSettings()
                    return settings.contentAlign
                end,
                setFunc = function(value)
                    local host = Nvk3UT and Nvk3UT.TrackerHost
                    if host and host.ApplyContentAlignment then
                        host.ApplyContentAlignment(value)
                    else
                        local settings = getHostSettings()
                        settings.contentAlign = normalizeContentAlign(value)
                    end
                end,
                default = DEFAULT_HOST_SETTINGS.contentAlign,
            })

            addControl({
                type = "dropdown",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_SCROLLBAR_SIDE),
                choices = {
                    GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_SCROLLBAR_SIDE_RIGHT),
                    GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_SCROLLBAR_SIDE_LEFT),
                },
                choicesValues = { "right", "left" },
                getFunc = function()
                    local settings = getHostSettings()
                    return settings.scrollbarSide
                end,
                setFunc = function(value)
                    local settings = getHostSettings()
                    settings.scrollbarSide = normalizeScrollbarSide(value)
                    if Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.ApplyAppearance then
                        Nvk3UT.TrackerHost.ApplyAppearance()
                    end
                end,
                default = DEFAULT_HOST_SETTINGS.scrollbarSide,
            })

            return controls
        end)(),
    }

    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_SECTION_TRACKER_ORDER),
        controls = buildTrackerOrderControls(),
    }



    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_QUEST_SECTION),
        controls = (function()
            local controls = {}
            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_QUEST_HEADER) }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_QUEST_ENABLE),
                tooltip = GetString(SI_NVK3UT_LAM_QUEST_ENABLE_DESC),
                getFunc = function()
                    local settings = getQuestSettings()
                    return settings.active ~= false
                end,
                setFunc = function(value)
                    local settings = getQuestSettings()
                    local normalized = value ~= false
                    settings.active = normalized

                    debugLog("LAM: QuestTracker enabled=%s", tostring(normalized))

                    if Nvk3UT and Nvk3UT.QuestTracker and Nvk3UT.QuestTracker.SetActive then
                        Nvk3UT.QuestTracker.SetActive(normalized)
                    end

                    local controller = Nvk3UT and Nvk3UT.QuestTrackerController
                    if controller and controller.RequestRefresh then
                        controller:RequestRefresh("LAM:SetActive")
                    else
                        local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
                        if runtime and runtime.QueueDirty then
                            runtime:QueueDirty("quest")
                        end
                    end

                    if Nvk3UT and Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then
                        Nvk3UT.UI.UpdateStatus()
                    end

                    local host = Nvk3UT and Nvk3UT.TrackerHost
                    if host and host.ApplyVisibilityRules then
                        host:ApplyVisibilityRules()
                    end

                    if Nvk3UT and Nvk3UT.QuestTracker and type(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility) == "function" then
                        pcall(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility)
                    elseif Nvk3UT and type(Nvk3UT.ApplyBaseQuestTrackerVisibility) == "function" then
                        pcall(Nvk3UT.ApplyBaseQuestTrackerVisibility)
                    end

                    LamQueueFullRebuild("questActive")
                end,
                default = true,
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_TRACKER_HOST_HIDE_DEFAULT),
                getFunc = function()
                    local general = getGeneral()
                    if general then
                        return general.hideBaseQuestTracker == true
                    end
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    if general then
                        general.hideBaseQuestTracker = (value == true)

                        if Nvk3UT and Nvk3UT.Debug then
                            Nvk3UT.Debug("LAM: hideBaseQuestTracker set to %s", tostring(general.hideBaseQuestTracker))
                        end
                    end

                    if Nvk3UT and Nvk3UT.QuestTracker and type(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility) == "function" then
                        pcall(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility)
                    elseif Nvk3UT and type(Nvk3UT.ApplyBaseQuestTrackerVisibility) == "function" then
                        pcall(Nvk3UT.ApplyBaseQuestTrackerVisibility)
                    end
                end,
                default = true,
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_QUEST_AUTO_EXPAND),
                tooltip = GetString(SI_NVK3UT_LAM_QUEST_AUTO_EXPAND_DESC),
                getFunc = function()
                    local settings = getQuestSettings()
                    return settings.autoExpand ~= false
                end,
                setFunc = function(value)
                    local settings = getQuestSettings()
                    settings.autoExpand = value
                    applyQuestSettings()
                end,
                default = true,
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_QUEST_AUTO_TRACK),
                tooltip = GetString(SI_NVK3UT_LAM_QUEST_AUTO_TRACK_DESC),
                getFunc = function()
                    local settings = getQuestSettings()
                    return settings.autoTrack ~= false
                end,
                setFunc = function(value)
                    local settings = getQuestSettings()
                    settings.autoTrack = value ~= false
                    applyQuestSettings()
                end,
                default = true,
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_QUEST_COLLAPSE_PREVIOUS_ON_ACTIVE_CHANGE),
                tooltip = GetString(SI_NVK3UT_LAM_QUEST_COLLAPSE_PREVIOUS_ON_ACTIVE_CHANGE_DESC),
                getFunc = function()
                    local settings = getQuestSettings()
                    return settings.autoCollapsePreviousCategoryOnActiveQuestChange == true
                end,
                setFunc = function(value)
                    local settings = getQuestSettings()
                    settings.autoCollapsePreviousCategoryOnActiveQuestChange = value == true
                end,
                default = false,
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_QUEST_SHOW_COUNTS),
                tooltip = GetString(SI_NVK3UT_LAM_QUEST_SHOW_COUNTS_DESC),
                getFunc = function()
                    local general = getGeneral()
                    return general.showQuestCategoryCounts ~= false
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    general.showQuestCategoryCounts = value ~= false
                    refreshQuestTracker()
                end,
                default = true,
            }

            controls[#controls + 1] = {
                type = "dropdown",
                name = GetString(SI_NVK3UT_QUEST_FILTER_MODE),
                choices = {
                    GetString(SI_NVK3UT_QUEST_FILTER_MODE_ALL),
                    GetString(SI_NVK3UT_QUEST_FILTER_MODE_ACTIVE),
                    GetString(SI_NVK3UT_QUEST_FILTER_MODE_SELECTION),
                },
                choicesValues = { 1, 2, 3 },
                getFunc = function()
                    local tracker = Nvk3UT and Nvk3UT.QuestTracker
                    if tracker and tracker.GetQuestFilterMode then
                        local ok, mode = pcall(tracker.GetQuestFilterMode)
                        if ok and mode ~= nil then
                            return mode
                        end
                    end

                    return QUEST_FILTER_MODE_ALL
                end,
                setFunc = function(value)
                    local numeric = tonumber(value) or QUEST_FILTER_MODE_ALL
                    if numeric ~= QUEST_FILTER_MODE_ACTIVE and numeric ~= QUEST_FILTER_MODE_SELECTION then
                        numeric = QUEST_FILTER_MODE_ALL
                    end

                    local filter = getQuestFilter()
                    if filter then
                        filter.mode = numeric
                    end

                    local controller = Nvk3UT and Nvk3UT.QuestTrackerController
                    if controller and controller.RequestRefresh then
                        controller:RequestRefresh("LAM:QuestFilterMode")
                    else
                        local tracker = Nvk3UT and Nvk3UT.QuestTracker
                        if tracker and tracker.MarkDirty then
                            tracker.MarkDirty("LAM:QuestFilterMode")
                        end

                        local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
                        if runtime and runtime.QueueDirty then
                            runtime:QueueDirty("quest")
                        end
                    end

                    if tracker and tracker.UpdateQuestJournalSelectionKeyLabelVisibility then
                        tracker.UpdateQuestJournalSelectionKeyLabelVisibility("LAM:QuestFilterMode")
                    end
                end,
                default = 1,
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_QUEST_FILTER_AUTO_TRACK_NEW),
                tooltip = GetString(SI_NVK3UT_LAM_QUEST_FILTER_AUTO_TRACK_NEW_DESC),
                getFunc = function()
                    local filter = getQuestFilter()
                    return filter.autoTrackNewQuestsInSelectionMode ~= false
                end,
                setFunc = function(value)
                    local filter = getQuestFilter()
                    if filter then
                        filter.autoTrackNewQuestsInSelectionMode = value == true
                    end
                end,
                default = true,
                disabled = function()
                    local tracker = Nvk3UT and Nvk3UT.QuestTracker
                    if tracker and tracker.GetQuestFilterMode then
                        local ok, mode = pcall(tracker.GetQuestFilterMode)
                        if ok then
                            return mode ~= QUEST_FILTER_MODE_SELECTION
                        end
                    end

                    return false
                end,
            }

            local function buildQuestColorControls()
                local colorControls = {}

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_QUEST_COLOR_CATEGORY),
                    tooltip = GetString(SI_NVK3UT_LAM_QUEST_COLOR_CATEGORY_DESC),
                    getFunc = function()
                        return getTrackerColor("questTracker", "categoryTitle")
                    end,
                    setFunc = function(r, g, b, a)
                        setTrackerColor("questTracker", "categoryTitle", r, g, b, a or 1)
                        refreshQuestTracker()
                    end,
                    default = getTrackerColorDefaultTable("questTracker", "categoryTitle"),
                }

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_QUEST_COLOR_ENTRY),
                    tooltip = GetString(SI_NVK3UT_LAM_QUEST_COLOR_ENTRY_DESC),
                    getFunc = function()
                        return getTrackerColor("questTracker", "entryTitle")
                    end,
                    setFunc = function(r, g, b, a)
                        setTrackerColor("questTracker", "entryTitle", r, g, b, a or 1)
                        refreshQuestTracker()
                    end,
                    default = getTrackerColorDefaultTable("questTracker", "entryTitle"),
                }

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_QUEST_COLOR_OBJECTIVE),
                    tooltip = GetString(SI_NVK3UT_LAM_QUEST_COLOR_OBJECTIVE_DESC),
                    getFunc = function()
                        return getTrackerColor("questTracker", "objectiveText")
                    end,
                    setFunc = function(r, g, b, a)
                        setTrackerColor("questTracker", "objectiveText", r, g, b, a or 1)
                        refreshQuestTracker()
                    end,
                    default = getTrackerColorDefaultTable("questTracker", "objectiveText"),
                }

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_QUEST_COLOR_ACTIVE),
                    tooltip = GetString(SI_NVK3UT_LAM_QUEST_COLOR_ACTIVE_DESC),
                    getFunc = function()
                        return getTrackerColor("questTracker", "activeTitle")
                    end,
                    setFunc = function(r, g, b, a)
                        setTrackerColor("questTracker", "activeTitle", r, g, b, a or 1)
                        refreshQuestTracker()
                    end,
                    default = getTrackerColorDefaultTable("questTracker", "activeTitle"),
                }

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_QUEST_COLOR_HIGHLIGHT),
                    tooltip = GetString(SI_NVK3UT_LAM_QUEST_COLOR_HIGHLIGHT_DESC),
                    getFunc = function()
                        return getMouseoverHighlightColor("questTracker")
                    end,
                    setFunc = function(r, g, b, a)
                        setMouseoverHighlightColor("questTracker", r, g, b, a or 1)
                    end,
                    default = getMouseoverHighlightDefaultTable("questTracker"),
                }

                return colorControls
            end

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_QUEST_HEADER_COLORS),
                controls = buildQuestColorControls(),
            }

            local function buildQuestFontControls()
                local fontControls = {}

                local fontGroups = {
                    { key = "category", label = GetString(SI_NVK3UT_LAM_QUEST_FONT_CATEGORY_LABEL) },
                    { key = "title", label = GetString(SI_NVK3UT_LAM_QUEST_FONT_TITLE_LABEL) },
                    { key = "line", label = GetString(SI_NVK3UT_LAM_QUEST_FONT_LINE_LABEL) },
                }

                for index = 1, #fontGroups do
                    local group = fontGroups[index]
                    local groupFontControls = buildFontControls(
                        group.label,
                        getQuestSettings(),
                        group.key,
                        questFontDefaults(group.key),
                        function()
                            applyQuestTheme()
                            refreshQuestTracker()
                        end
                    )
                    for i = 1, #groupFontControls do
                        fontControls[#fontControls + 1] = groupFontControls[i]
                    end
                end

                return fontControls
            end

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_QUEST_HEADER_FONTS),
                controls = buildQuestFontControls(),
            }

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_SPACING_QUEST_SUBMENU),
                controls = buildSpacingControls("quest"),
            }

            return controls
        end)(),
    }
    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_ENDEAVOR_SECTION),
        controls = (function()
            local controls = {}
            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_ENDEAVOR_HEADER_FUNCTIONS) }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_ENDEAVOR_ENABLE),
                tooltip = GetString(SI_NVK3UT_LAM_ENDEAVOR_ENABLE_DESC),
                getFunc = function()
                    local config = getEndeavorConfig()
                    if config.Enabled == nil then
                        local achievement = getAchievementSettings()
                        return achievement.active ~= false
                    end
                    return config.Enabled ~= false
                end,
                setFunc = function(value)
                    local config = getEndeavorConfig()
                    config.Enabled = value ~= false
                    refreshEndeavorModel()
                    if LamQueueFullRebuild("endeavorEnable") then
                        return
                    end
                    markEndeavorDirty("enable")
                    queueEndeavorDirty()
                end,
                default = (function()
                    local achievement = getAchievementSettings()
                    return achievement.active ~= false
                end)(),
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_ENDEAVOR_SHOW_COUNTS),
                tooltip = GetString(SI_NVK3UT_LAM_ENDEAVOR_SHOW_COUNTS_DESC),
                getFunc = function()
                    local config = getEndeavorConfig()
                    if config.ShowCountsInHeaders == nil then
                        local general = getGeneral()
                        return general.showAchievementCategoryCounts ~= false
                    end
                    return config.ShowCountsInHeaders ~= false
                end,
                setFunc = function(value)
                    local config = getEndeavorConfig()
                    config.ShowCountsInHeaders = value ~= false
                    markEndeavorDirty("headers")
                    queueEndeavorDirty()
                end,
                default = (function()
                    local general = getGeneral()
                    return general.showAchievementCategoryCounts ~= false
                end)(),
            }

            controls[#controls + 1] = {
                type = "dropdown",
                name = GetString(SI_NVK3UT_LAM_ENDEAVOR_COMPLETED_HEADER),
                tooltip = GetString(SI_NVK3UT_LAM_ENDEAVOR_COMPLETED_HEADER_DESC),
                choices = {
                    GetString(SI_NVK3UT_LAM_ENDEAVOR_COMPLETED_HIDE),
                    GetString(SI_NVK3UT_LAM_ENDEAVOR_COMPLETED_RECOLOR),
                },
                choicesValues = { "hide", "recolor" },
                getFunc = function()
                    local config = getEndeavorConfig()
                    if config.CompletedHandling == "recolor" then
                        return "recolor"
                    end
                    return "hide"
                end,
                setFunc = function(value)
                    local config = getEndeavorConfig()
                    local resolved = value == "recolor" and "recolor" or "hide"
                    config.CompletedHandling = resolved
                    refreshEndeavorModel()
                    if LamQueueFullRebuild("endeavorCompletedHandling") then
                        return
                    end
                    if resolved == "hide" then
                        markEndeavorDirty("filter")
                    else
                        markEndeavorDirty("appearance")
                    end
                    queueEndeavorDirty()
                end,
                default = "hide",
            }

            local function buildEndeavorColorControls()
                local colorControls = {}

                local colorEntries = {
                    {
                        key = "CategoryTitle",
                        role = ENDEAVOR_COLOR_ROLES.CategoryTitle,
                        name = SI_NVK3UT_LAM_ENDEAVOR_COLOR_CATEGORY,
                        tooltip = SI_NVK3UT_LAM_ENDEAVOR_COLOR_CATEGORY_DESC,
                    },
                    {
                        key = "EntryName",
                        role = ENDEAVOR_COLOR_ROLES.EntryName,
                        name = SI_NVK3UT_LAM_ENDEAVOR_COLOR_ENTRY,
                        tooltip = SI_NVK3UT_LAM_ENDEAVOR_COLOR_ENTRY_DESC,
                    },
                    {
                        key = "Objective",
                        role = ENDEAVOR_COLOR_ROLES.Objective,
                        name = SI_NVK3UT_LAM_ENDEAVOR_COLOR_OBJECTIVE,
                        tooltip = SI_NVK3UT_LAM_ENDEAVOR_COLOR_OBJECTIVE_DESC,
                    },
                    {
                        key = "Active",
                        role = ENDEAVOR_COLOR_ROLES.Active,
                        name = SI_NVK3UT_LAM_ENDEAVOR_COLOR_ACTIVE,
                        tooltip = SI_NVK3UT_LAM_ENDEAVOR_COLOR_ACTIVE_DESC,
                    },
                    {
                        key = "Completed",
                        role = ENDEAVOR_COLOR_ROLES.Completed,
                        name = SI_NVK3UT_LAM_ENDEAVOR_COLOR_COMPLETED,
                        tooltip = SI_NVK3UT_LAM_ENDEAVOR_COLOR_COMPLETED_DESC,
                    },
                }

                local function getAchievementColorDefault(colorKey)
                    local sv = getSavedVars()
                    if type(sv) ~= "table" then
                        return nil
                    end

                    local achievement = sv.Achievement
                    if type(achievement) ~= "table" then
                        return nil
                    end

                    local colors = achievement.Colors
                    if type(colors) ~= "table" then
                        return nil
                    end

                    local candidate = colors[colorKey]
                    if candidate == nil and colorKey == "Completed" then
                        candidate = colors.Completed or colors.Objective
                    end

                    if type(candidate) ~= "table" then
                        return nil
                    end

                    local r = candidate[1] or candidate.r or 1
                    local g = candidate[2] or candidate.g or 1
                    local b = candidate[3] or candidate.b or 1
                    local a = candidate[4] or candidate.a or 1
                    return r, g, b, a
                end

                local function getEndeavorDefaultColor(colorKey, role)
                    local r, g, b, a = getAchievementColorDefault(colorKey)
                    if r ~= nil then
                        return r, g, b, a
                    end

                    local fallback = getTrackerColorDefaultTable("endeavorTracker", role)
                    if type(fallback) == "table" then
                        local fallbackR = fallback[1] or fallback.r or 1
                        local fallbackG = fallback[2] or fallback.g or 1
                        local fallbackB = fallback[3] or fallback.b or 1
                        local fallbackA = fallback[4] or fallback.a or 1
                        return fallbackR, fallbackG, fallbackB, fallbackA
                    end

                    if colorKey == "Completed" then
                        return 0.8, 0.8, 0.8, 1
                    end

                    return 1, 1, 1, 1
                end

                for index = 1, #colorEntries do
                    local entry = colorEntries[index]
                    colorControls[#colorControls + 1] = {
                        type = "colorpicker",
                        name = GetString(entry.name),
                        tooltip = GetString(entry.tooltip),
                        width = "full",
                        getFunc = function()
                            local config = getEndeavorConfig()
                            local colors = config.Colors or {}
                            local color = colors[entry.key]
                            local r = (color and (color[1] or color.r)) or 1
                            local g = (color and (color[2] or color.g)) or 1
                            local b = (color and (color[3] or color.b)) or 1
                            local a = (color and (color[4] or color.a)) or 1
                            return r, g, b, a
                        end,
                        setFunc = function(r, g, b, a)
                            local config = getEndeavorConfig()
                            config.Colors = config.Colors or {}
                            config.Colors[entry.key] = config.Colors[entry.key] or { 1, 1, 1, 1 }
                            local color = config.Colors[entry.key]
                            local alpha = a or 1
                            color[1], color[2], color[3], color[4] = r, g, b, alpha
                            color.r, color.g, color.b, color.a = r, g, b, alpha
                            setTrackerColor("endeavorTracker", entry.role, r, g, b, alpha)
                            markEndeavorDirty("appearance")
                            queueEndeavorDirty()
                        end,
                        default = function()
                            return getEndeavorDefaultColor(entry.key, entry.role)
                        end,
                    }
                end

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_ENDEAVOR_COLOR_HIGHLIGHT),
                    tooltip = GetString(SI_NVK3UT_LAM_ENDEAVOR_COLOR_HIGHLIGHT_DESC),
                    getFunc = function()
                        return getMouseoverHighlightColor("endeavorTracker")
                    end,
                    setFunc = function(r, g, b, a)
                        setMouseoverHighlightColor("endeavorTracker", r, g, b, a or 1)
                    end,
                    default = getMouseoverHighlightDefaultTable("endeavorTracker"),
                }

                return colorControls
            end

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_ENDEAVOR_SECTION_COLORS),
                controls = buildEndeavorColorControls(),
            }

            local function buildEndeavorFontControls()
                local fontControls = {}

                local fontGroups = {
                    { key = "Category", label = GetString(SI_NVK3UT_LAM_ENDEAVOR_FONT_CATEGORY_LABEL) },
                    { key = "Title", label = GetString(SI_NVK3UT_LAM_ENDEAVOR_FONT_TITLE_LABEL) },
                    { key = "Objective", label = GetString(SI_NVK3UT_LAM_ENDEAVOR_FONT_LINE_LABEL) },
                }

                local config = getEndeavorConfig()
                for index = 1, #fontGroups do
                    local group = fontGroups[index]
                    local defaultsFactory = function()
                        return endeavorFontDefaults(group.key)
                    end
                    local defaultsValue = defaultsFactory()
                    local groupFontControls = buildFontControls(
                        group.label,
                        config,
                        group.key,
                        defaultsFactory,
                        function()
                            markEndeavorDirty("appearance")
                            queueEndeavorDirty()
                        end,
                        {
                            ensureFont = ensureEndeavorFontGroup,
                            getFace = function(font)
                                return font.Face
                            end,
                            setFace = function(font, value)
                                font.Face = value
                            end,
                            getSize = function(font)
                                return font.Size
                            end,
                            setSize = function(font, value)
                                font.Size = clampEndeavorFontSize(value)
                            end,
                            getOutline = function(font)
                                return font.Outline
                            end,
                            setOutline = function(font, value)
                                font.Outline = value
                            end,
                            clampSize = clampEndeavorFontSize,
                        }
                    )

                    for i = 1, #groupFontControls do
                        local control = groupFontControls[i]
                        if i == 1 then
                            control.tooltip = GetString(SI_NVK3UT_LAM_ENDEAVOR_FONT_FAMILY_DESC)
                            control.default = defaultsValue.Face
                        elseif i == 2 then
                            control.tooltip = GetString(SI_NVK3UT_LAM_ENDEAVOR_FONT_SIZE_DESC)
                            control.default = defaultsValue.Size
                        else
                            control.tooltip = GetString(SI_NVK3UT_LAM_ENDEAVOR_FONT_OUTLINE_DESC)
                            control.default = defaultsValue.Outline
                        end
                        fontControls[#fontControls + 1] = control
                    end
                end

                return fontControls
            end

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_ENDEAVOR_SECTION_FONTS),
                controls = buildEndeavorFontControls(),
            }
            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_SPACING_ENDEAVOR_SUBMENU),
                controls = buildSpacingControls("endeavor"),
            }
            return controls
        end)(),
    }

    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_SECTION),
        controls = (function()
            local controls = {}
            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_HEADER) }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_ENABLE),
                tooltip = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_ENABLE_DESC),
                getFunc = function()
                    local settings = getAchievementSettings()
                    return settings.active ~= false
                end,
                setFunc = function(value)
                    local settings = getAchievementSettings()
                    local normalized = value ~= false
                    settings.active = normalized

                    debugLog("LAM: AchievementTracker enabled=%s", tostring(normalized))

                    if Nvk3UT and Nvk3UT.AchievementTracker and Nvk3UT.AchievementTracker.SetActive then
                        Nvk3UT.AchievementTracker.SetActive(normalized)
                    end

                    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
                    if runtime and runtime.QueueDirty then
                        runtime:QueueDirty("achievement")
                    end

                    local host = Nvk3UT and Nvk3UT.TrackerHost
                    if host and host.ApplyVisibilityRules then
                        host:ApplyVisibilityRules()
                    end

                    LamQueueFullRebuild("achievementActive")
                end,
                default = true,
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_SHOW_COUNTS),
                tooltip = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_SHOW_COUNTS_DESC),
                getFunc = function()
                    local general = getGeneral()
                    return general.showAchievementCategoryCounts ~= false
                end,
                setFunc = function(value)
                    local general = getGeneral()
                    general.showAchievementCategoryCounts = value ~= false
                    refreshAchievementTracker()
                end,
                default = true,
            }

            local function buildAchievementColorControls()
                local colorControls = {}

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_CATEGORY),
                    tooltip = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_CATEGORY_DESC),
                    getFunc = function()
                        return getTrackerColor("achievementTracker", "categoryTitle")
                    end,
                    setFunc = function(r, g, b, a)
                        setTrackerColor("achievementTracker", "categoryTitle", r, g, b, a or 1)
                        refreshAchievementTracker()
                    end,
                    default = getTrackerColorDefaultTable("achievementTracker", "categoryTitle"),
                }

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_ENTRY),
                    tooltip = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_ENTRY_DESC),
                    getFunc = function()
                        return getTrackerColor("achievementTracker", "entryTitle")
                    end,
                    setFunc = function(r, g, b, a)
                        setTrackerColor("achievementTracker", "entryTitle", r, g, b, a or 1)
                        refreshAchievementTracker()
                    end,
                    default = getTrackerColorDefaultTable("achievementTracker", "entryTitle"),
                }

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_OBJECTIVE),
                    tooltip = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_OBJECTIVE_DESC),
                    getFunc = function()
                        return getTrackerColor("achievementTracker", "objectiveText")
                    end,
                    setFunc = function(r, g, b, a)
                        setTrackerColor("achievementTracker", "objectiveText", r, g, b, a or 1)
                        refreshAchievementTracker()
                    end,
                    default = getTrackerColorDefaultTable("achievementTracker", "objectiveText"),
                }

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_ACTIVE),
                    tooltip = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_ACTIVE_DESC),
                    getFunc = function()
                        return getTrackerColor("achievementTracker", "activeTitle")
                    end,
                    setFunc = function(r, g, b, a)
                        setTrackerColor("achievementTracker", "activeTitle", r, g, b, a or 1)
                        refreshAchievementTracker()
                    end,
                    default = getTrackerColorDefaultTable("achievementTracker", "activeTitle"),
                }

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_HIGHLIGHT),
                    tooltip = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_COLOR_HIGHLIGHT_DESC),
                    getFunc = function()
                        return getMouseoverHighlightColor("achievementTracker")
                    end,
                    setFunc = function(r, g, b, a)
                        setMouseoverHighlightColor("achievementTracker", r, g, b, a or 1)
                    end,
                    default = getMouseoverHighlightDefaultTable("achievementTracker"),
                }

                return colorControls
            end

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_HEADER_COLORS),
                controls = buildAchievementColorControls(),
            }

            local function buildAchievementFontControls()
                local fontControls = {}

                local fontGroups = {
                    { key = "category", label = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_FONT_CATEGORY_LABEL) },
                    { key = "title", label = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_FONT_TITLE_LABEL) },
                    { key = "line", label = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_FONT_LINE_LABEL) },
                }

                for index = 1, #fontGroups do
                    local group = fontGroups[index]
                    local groupFontControls = buildFontControls(
                        group.label,
                        getAchievementSettings(),
                        group.key,
                        achievementFontDefaults(group.key),
                        function()
                            applyAchievementTheme()
                            refreshAchievementTracker()
                        end
                    )
                    for i = 1, #groupFontControls do
                        fontControls[#fontControls + 1] = groupFontControls[i]
                    end
                end

                return fontControls
            end

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_ACHIEVEMENT_HEADER_FONTS),
                controls = buildAchievementFontControls(),
            }
            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_SPACING_ACHIEVEMENT_SUBMENU),
                controls = buildSpacingControls("achievement"),
            }

            return controls
        end)(),
    }


    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_GOLDEN_SECTION),
        controls = (function()
            local controls = {}

            local function getGoldenDefaults()
                local sv = getSavedVars()
                local trackerDefaults = sv and sv.TrackerDefaults
                return trackerDefaults and trackerDefaults.GoldenDefaults or {}
            end

            controls[#controls + 1] = { type = "header", name = GetString(SI_NVK3UT_LAM_GOLDEN_HEADER_FUNCTIONS) }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_GOLDEN_ENABLE),
                tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_ENABLE_DESC),
                getFunc = function()
                    local config = getGoldenConfig()
                    if config.Enabled == nil then
                        local defaults = getGoldenDefaults()
                        if defaults.Enabled ~= nil then
                            return defaults.Enabled ~= false
                        end
                        return true
                    end
                    return config.Enabled ~= false
                end,
                setFunc = function(value)
                    local config = getGoldenConfig()
                    config.Enabled = value ~= false
                    refreshGoldenModel()
                    if LamQueueFullRebuild("goldenEnable") then
                        return
                    end
                    markGoldenDirty("enable")
                    queueGoldenDirty()
                end,
                default = (function()
                    local defaults = getGoldenDefaults()
                    if defaults.Enabled ~= nil then
                        return defaults.Enabled ~= false
                    end
                    return true
                end)(),
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_GOLDEN_HIDE_BASEGAME_TRACKING),
                tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_HIDE_BASEGAME_TRACKING_DESC),
                getFunc = function()
                    local config = getGoldenConfig()
                    if config and config.hideBaseGameTracking ~= nil then
                        return config.hideBaseGameTracking ~= false
                    end

                    local defaults = getGoldenDefaults()
                    if defaults and defaults.hideBaseGameTracking ~= nil then
                        return defaults.hideBaseGameTracking ~= false
                    end

                    return true
                end,
                setFunc = function(value)
                    local config = getGoldenConfig()
                    if config then
                        config.hideBaseGameTracking = value ~= false
                    end

                    local controller = Nvk3UT and Nvk3UT.GoldenTrackerController
                    local applyFn = controller and controller.applyBaseGameTrackerHidden
                    if type(applyFn) ~= "function" then
                        applyFn = controller and controller.ApplyBaseGameTrackerVisibility
                    end

                    if type(applyFn) == "function" then
                        applyFn(value)
                    end
                end,
                default = (function()
                    local defaults = getGoldenDefaults()
                    if defaults and defaults.hideBaseGameTracking ~= nil then
                        return defaults.hideBaseGameTracking ~= false
                    end
                    return true
                end)(),
            }

            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_GOLDEN_SHOW_COUNTS),
                tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_SHOW_COUNTS_DESC),
                getFunc = function()
                    local config = getGoldenConfig()
                    if config.ShowCountsInHeaders == nil then
                        local defaults = getGoldenDefaults()
                        if defaults.ShowCountsInHeaders ~= nil then
                            return defaults.ShowCountsInHeaders ~= false
                        end
                        return true
                    end
                    return config.ShowCountsInHeaders ~= false
                end,
                setFunc = function(value)
                    local config = getGoldenConfig()
                    config.ShowCountsInHeaders = value ~= false
                    markGoldenDirty("appearance")
                    queueGoldenDirty()
                end,
                default = (function()
                    local defaults = getGoldenDefaults()
                    if defaults.ShowCountsInHeaders ~= nil then
                        return defaults.ShowCountsInHeaders ~= false
                    end
                    return true
                end)(),
            }

            controls[#controls + 1] = {
                type = "dropdown",
                name = GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_HEADER_GENERAL),
                tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_HEADER_GENERAL_DESC),
                choices = {
                    GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_HIDE),
                    GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_RECOLOR),
                    GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_SHOW_OPEN_OBJECTIVES),
                },
                choicesValues = { "hide", "recolor", "showOpen" },
                getFunc = function()
                    local config = getGoldenConfig()
                    local value = config.generalCompletedHandling
                    if value == nil then
                        value = config.CompletedHandlingGeneral
                    end
                    if value == nil then
                        local legacy = config.CompletedHandling
                        if legacy == "recolor" then
                            return "recolor"
                        end
                        return "hide"
                    end
                    if value == "showOpen" then
                        return "showOpen"
                    end
                    if value == "recolor" then
                        return "recolor"
                    end
                    return "hide"
                end,
                setFunc = function(value)
                    local config = getGoldenConfig()
                    local resolved = "hide"
                    if value == "recolor" then
                        resolved = "recolor"
                    elseif value == "showOpen" then
                        resolved = "showOpen"
                    end
                    config.generalCompletedHandling = resolved
                    config.CompletedHandlingGeneral = resolved
                    if config.CompletedHandling ~= nil then
                        config.CompletedHandling = resolved == "recolor" and "recolor" or "hide"
                    end
                    refreshGoldenModel()
                    if LamQueueFullRebuild("goldenCompletedHandlingGeneral") then
                        return
                    end
                    markGoldenDirty(resolved == "hide" and "filter" or "appearance")
                    queueGoldenDirty()
                end,
                default = "hide",
            }

            controls[#controls + 1] = {
                type = "dropdown",
                name = GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_HEADER_OBJECTIVES),
                tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_HEADER_OBJECTIVES_DESC),
                choices = {
                    GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_HIDE),
                    GetString(SI_NVK3UT_LAM_GOLDEN_COMPLETED_RECOLOR),
                },
                choicesValues = { "hide", "recolor" },
                getFunc = function()
                    local config = getGoldenConfig()
                    local value = config.CompletedHandlingObjectives
                    if value == "recolor" then
                        return "recolor"
                    end
                    if value == "hide" then
                        return "hide"
                    end

                    local general = config.generalCompletedHandling or config.CompletedHandlingGeneral
                    if general == "recolor" or general == "hide" then
                        return general
                    end
                    return "hide"
                end,
                setFunc = function(value)
                    local config = getGoldenConfig()
                    local resolved = value == "recolor" and "recolor" or "hide"
                    config.CompletedHandlingObjectives = resolved
                    refreshGoldenModel()
                    if LamQueueFullRebuild("goldenCompletedHandlingObjectives") then
                        return
                    end
                    if resolved == "hide" then
                        markGoldenDirty("filter")
                    else
                        markGoldenDirty("appearance")
                    end
                    queueGoldenDirty()
                end,
                default = "hide",
            }

            local function buildGoldenColorControls()
                local colorControls = {}

                local colorEntries = {
                    {
                        key = "CategoryTitleClosed",
                        role = GOLDEN_COLOR_ROLES.CategoryTitleClosed,
                        name = SI_NVK3UT_LAM_GOLDEN_COLOR_CATEGORY_CLOSED,
                        tooltip = SI_NVK3UT_LAM_GOLDEN_COLOR_CATEGORY_CLOSED_DESC,
                    },
                    {
                        key = "CategoryTitleOpen",
                        role = GOLDEN_COLOR_ROLES.CategoryTitleOpen,
                        name = SI_NVK3UT_LAM_GOLDEN_COLOR_CATEGORY_OPEN,
                        tooltip = SI_NVK3UT_LAM_GOLDEN_COLOR_CATEGORY_OPEN_DESC,
                    },
                    {
                        key = "EntryName",
                        role = GOLDEN_COLOR_ROLES.EntryName,
                        name = SI_NVK3UT_LAM_GOLDEN_COLOR_ENTRY,
                        tooltip = SI_NVK3UT_LAM_GOLDEN_COLOR_ENTRY_DESC,
                    },
                    {
                        key = "Objective",
                        role = GOLDEN_COLOR_ROLES.Objective,
                        name = SI_NVK3UT_LAM_GOLDEN_COLOR_OBJECTIVE,
                        tooltip = SI_NVK3UT_LAM_GOLDEN_COLOR_OBJECTIVE_DESC,
                    },
                    {
                        key = "Active",
                        role = GOLDEN_COLOR_ROLES.Active,
                        name = SI_NVK3UT_LAM_GOLDEN_COLOR_ACTIVE,
                        tooltip = SI_NVK3UT_LAM_GOLDEN_COLOR_ACTIVE_DESC,
                    },
                    {
                        key = "Completed",
                        role = GOLDEN_COLOR_ROLES.Completed,
                        name = SI_NVK3UT_LAM_GOLDEN_COLOR_COMPLETED,
                        tooltip = SI_NVK3UT_LAM_GOLDEN_COLOR_COMPLETED_DESC,
                    },
                }

                local function getGoldenDefaultColor(colorKey, role)
                    local defaults = getGoldenDefaults()
                    local colors = defaults.Colors
                    local sourceKey = colorKey
                    if colorKey == "CategoryTitleClosed" then
                        sourceKey = "CategoryTitle"
                    elseif colorKey == "CategoryTitleOpen" then
                        sourceKey = "EntryName"
                    end

                    if type(colors) == "table" then
                        local candidate = colors[sourceKey]
                        if type(candidate) == "table" then
                            local r = candidate[1] or candidate.r or 1
                            local g = candidate[2] or candidate.g or 1
                            local b = candidate[3] or candidate.b or 1
                            local a = candidate[4] or candidate.a or 1
                            return r, g, b, a
                        end
                    end

                    local fallbackRole = role
                    if colorKey == "CategoryTitleClosed" then
                        fallbackRole = ENDEAVOR_COLOR_ROLES.CategoryTitle
                    elseif colorKey == "CategoryTitleOpen" then
                        fallbackRole = ENDEAVOR_COLOR_ROLES.EntryName
                    elseif colorKey == "EntryName" then
                        fallbackRole = ENDEAVOR_COLOR_ROLES.EntryName
                    elseif colorKey == "Objective" then
                        fallbackRole = ENDEAVOR_COLOR_ROLES.Objective
                    elseif colorKey == "Active" then
                        fallbackRole = ENDEAVOR_COLOR_ROLES.Active
                    elseif colorKey == "Completed" then
                        fallbackRole = ENDEAVOR_COLOR_ROLES.Completed
                    end

                    local fallback = getTrackerColorDefaultTable("endeavorTracker", fallbackRole or role)
                    if type(fallback) == "table" then
                        local r = fallback[1] or fallback.r or 1
                        local g = fallback[2] or fallback.g or 1
                        local b = fallback[3] or fallback.b or 1
                        local a = fallback[4] or fallback.a or 1
                        return r, g, b, a
                    end

                    return 1, 1, 1, 1
                end

                for index = 1, #colorEntries do
                    local entry = colorEntries[index]
                    colorControls[#colorControls + 1] = {
                        type = "colorpicker",
                        name = GetString(entry.name),
                        tooltip = GetString(entry.tooltip),
                        width = "full",
                        getFunc = function()
                            local config = getGoldenConfig()
                            local colors = config.Colors or {}
                            local color = colors[entry.key]
                            local r = (color and (color[1] or color.r)) or 1
                            local g = (color and (color[2] or color.g)) or 1
                            local b = (color and (color[3] or color.b)) or 1
                            local a = (color and (color[4] or color.a)) or 1
                            return r, g, b, a
                        end,
                        setFunc = function(r, g, b, a)
                            local alpha = a or 1
                            setGoldenColor(entry.key, entry.role, r, g, b, alpha)
                            markGoldenDirty("appearance")
                            queueGoldenDirty()
                        end,
                        default = function()
                            return getGoldenDefaultColor(entry.key, entry.role)
                        end,
                    }
                end

                colorControls[#colorControls + 1] = {
                    type = "colorpicker",
                    name = GetString(SI_NVK3UT_LAM_GOLDEN_COLOR_HIGHLIGHT),
                    tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_COLOR_HIGHLIGHT_DESC),
                    getFunc = function()
                        return getMouseoverHighlightColor("goldenTracker")
                    end,
                    setFunc = function(r, g, b, a)
                        setMouseoverHighlightColor("goldenTracker", r, g, b, a or 1)
                    end,
                    default = getMouseoverHighlightDefaultTable("goldenTracker"),
                }

                return colorControls
            end

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_GOLDEN_SECTION_COLORS),
                controls = buildGoldenColorControls(),
            }

            local function buildGoldenFontControls()
                local fontControls = {}

                local fontGroups = {
                    { key = "Category", label = GetString(SI_NVK3UT_LAM_GOLDEN_FONT_CATEGORY_LABEL) },
                    { key = "Title", label = GetString(SI_NVK3UT_LAM_GOLDEN_FONT_TITLE_LABEL) },
                    { key = "Objective", label = GetString(SI_NVK3UT_LAM_GOLDEN_FONT_LINE_LABEL) },
                }

                local config = getGoldenConfig()
                for index = 1, #fontGroups do
                    local group = fontGroups[index]
                    local defaultsFactory = function()
                        return goldenFontDefaults(group.key)
                    end
                    local defaultsValue = defaultsFactory()
                    local groupFontControls = buildFontControls(
                        group.label,
                        config,
                        group.key,
                        defaultsFactory,
                        function()
                            markGoldenDirty("appearance")
                            queueGoldenDirty()
                        end,
                        {
                            ensureFont = ensureGoldenFontGroup,
                            getFace = function(font)
                                return font.Face or font.face
                            end,
                            setFace = function(font, value)
                                font.face = value
                                font.Face = value
                            end,
                            getSize = function(font)
                                return font.Size or font.size
                            end,
                            setSize = function(font, value)
                                local resolved = clampEndeavorFontSize(value)
                                font.size = resolved
                                font.Size = resolved
                            end,
                            getOutline = function(font)
                                return font.Outline or font.outline
                            end,
                            setOutline = function(font, value)
                                font.outline = value
                                font.Outline = value
                            end,
                            clampSize = clampEndeavorFontSize,
                        }
                    )

                    for i = 1, #groupFontControls do
                        local control = groupFontControls[i]
                        if i == 1 then
                            control.tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_FONT_FAMILY_DESC)
                            control.default = defaultsValue.face or defaultsValue.Face
                        elseif i == 2 then
                            control.tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_FONT_SIZE_DESC)
                            control.default = defaultsValue.size or defaultsValue.Size
                        else
                            control.tooltip = GetString(SI_NVK3UT_LAM_GOLDEN_FONT_OUTLINE_DESC)
                            control.default = defaultsValue.outline or defaultsValue.Outline
                        end
                        fontControls[#fontControls + 1] = control
                    end
                end

                return fontControls
            end

            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_GOLDEN_SECTION_FONTS),
                controls = buildGoldenFontControls(),
            }
            controls[#controls + 1] = {
                type = "submenu",
                name = GetString(SI_NVK3UT_LAM_SPACING_GOLDEN_SUBMENU),
                controls = buildSpacingControls("golden"),
            }

            return controls
        end)(),
    }
    options[#options + 1] = {
        type = "submenu",
        name = GetString(SI_NVK3UT_LAM_SECTION_DEBUG),
        controls = (function()
            local controls = {}
            controls[#controls + 1] = {
                type = "checkbox",
                name = GetString(SI_NVK3UT_LAM_OPTION_DEBUG_ENABLE),
                getFunc = function()
                    local sv = getSavedVars()
                    return sv.debug == true
                end,
                setFunc = function(value)
                    local sv = getSavedVars()
                    local enabled = value and true or false
                    sv.debug = enabled
                    local addon = Nvk3UT
                    if addon and type(addon.SetDebugEnabled) == "function" then
                        addon:SetDebugEnabled(enabled)
                    end
                    local diagnostics = (addon and addon.Diagnostics) or Nvk3UT_Diagnostics
                    if diagnostics and type(diagnostics.SetDebugEnabled) == "function" then
                        diagnostics.SetDebugEnabled(enabled)
                    end
                end,
                default = false,
            }

            controls[#controls + 1] = {
                type = "button",
                name = GetString(SI_NVK3UT_LAM_OPTION_SELF_TEST),
                func = function()
                    local module = nil
                    if Nvk3UT and Nvk3UT.SelfTest then
                        module = Nvk3UT.SelfTest
                    elseif rawget(_G, "Nvk3UT_SelfTest") then
                        module = Nvk3UT_SelfTest
                    end

                    if module and type(module.Run) == "function" then
                        if Nvk3UT_Diagnostics and type(Nvk3UT_Diagnostics.Warn) == "function" then
                            Nvk3UT_Diagnostics.Warn("Self-Test requested from settings panel")
                        elseif type(d) == "function" then
                            d("[Nvk3UT WARN] Self-Test requested from settings panel")
                        end

                        local ok, err = pcall(module.Run)
                        if not ok then
                            local message = string.format("Self-Test failed to execute: %s", tostring(err))
                            if Nvk3UT_Diagnostics and type(Nvk3UT_Diagnostics.Error) == "function" then
                                Nvk3UT_Diagnostics.Error(message)
                            elseif type(d) == "function" then
                                d(string.format("|cFF0000[Nvk3UT ERROR]|r %s", message))
                            end
                        end
                    else
                        local message = "Self-Test module not available; cannot run diagnostics"
                        if Nvk3UT_Diagnostics and type(Nvk3UT_Diagnostics.Error) == "function" then
                            Nvk3UT_Diagnostics.Error(message)
                        elseif type(d) == "function" then
                            d(string.format("|cFF0000[Nvk3UT ERROR]|r %s", message))
                        end
                    end
                end,
                tooltip = GetString(SI_NVK3UT_LAM_OPTION_SELF_TEST_DESC),
            }

            controls[#controls + 1] = {
                type = "button",
                name = GetString(SI_NVK3UT_LAM_OPTION_RELOAD_UI),
                func = function()
                    ReloadUI()
                end,
            }

            return controls
        end)(),
    }

    LAM:RegisterAddonPanel(panelName, panel)
    LAM:RegisterOptionControls(panelName, options)

    registerLamCallbacks(LAM, panelName, panel)

    L._registered = true
    return true
end

local lamWaitEventName = "Nvk3UT_LAM_WaitForLibrary"
local lamWaitRegistered = false
local pendingPanelTitle = nil

local function waitForLam()
    if lamWaitRegistered then
        return
    end

    if not EVENT_MANAGER then
        return
    end

    lamWaitRegistered = true

    EVENT_MANAGER:RegisterForEvent(lamWaitEventName, EVENT_ADD_ON_LOADED, function(_, addonName)
        if addonName ~= "LibAddonMenu-2.0" then
            return
        end

        if registerPanel(pendingPanelTitle) then
            EVENT_MANAGER:UnregisterForEvent(lamWaitEventName, EVENT_ADD_ON_LOADED)
            lamWaitRegistered = false
        end
    end)

    if zo_callLater then
        local attempts = 0
        local function retry()
            if L._registered then
                return
            end

            attempts = attempts + 1
            if registerPanel(pendingPanelTitle) then
                if EVENT_MANAGER then
                    EVENT_MANAGER:UnregisterForEvent(lamWaitEventName, EVENT_ADD_ON_LOADED)
                end
                lamWaitRegistered = false
                return
            end

            if attempts < 10 then
                zo_callLater(retry, 500)
            end
        end

        zo_callLater(retry, 500)
    end
end

function L.Build(displayTitle)
    if L._registered then
        return
    end

    pendingPanelTitle = displayTitle or pendingPanelTitle or DEFAULT_PANEL_TITLE

    if registerPanel(pendingPanelTitle) then
        return
    end

    waitForLam()
end

local function ensureRegisteredWhenReady()
    if L._registered then
        return
    end

    if not (Nvk3UT and Nvk3UT.sv) then
        if zo_callLater then
            zo_callLater(ensureRegisteredWhenReady, 100)
        end
        return
    end

    pendingPanelTitle = pendingPanelTitle or DEFAULT_PANEL_TITLE

    if registerPanel(pendingPanelTitle) then
        return
    end

    waitForLam()
end

if EVENT_MANAGER then
    local lamInitEvent = "Nvk3UT_LAM_OnAddonLoaded"
    EVENT_MANAGER:RegisterForEvent(lamInitEvent, EVENT_ADD_ON_LOADED, function(_, addonName)
        if addonName ~= ADDON_NAME then
            return
        end

        EVENT_MANAGER:UnregisterForEvent(lamInitEvent, EVENT_ADD_ON_LOADED)

        ensureRegisteredWhenReady()
    end)
end

return L
