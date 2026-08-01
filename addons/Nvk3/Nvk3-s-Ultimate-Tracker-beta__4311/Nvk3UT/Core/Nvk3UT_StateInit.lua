-- Core/Nvk3UT_StateInit.lua
-- Centralized SavedVariables bootstrap and first-login defaults for Nvk3UT.
-- This module does NOT register ESO events, does NOT create UI, and does NOT call ReloadUI.

Nvk3UT_StateInit = Nvk3UT_StateInit or {}

local function ShallowCopy(dst, src)
    if type(dst) ~= "table" then
        dst = {}
    end
    if type(src) == "table" then
        for k, v in pairs(src) do
            dst[k] = v
        end
    end
    return dst
end

local function Ensure(tbl, key, default)
    if type(tbl) ~= "table" then
        if type(default) == "table" then
            return ShallowCopy({}, default)
        end
        return default
    end

    local value = tbl[key]
    if value == nil then
        if type(default) == "table" then
            value = ShallowCopy({}, default)
        else
            value = default
        end
        tbl[key] = value
    end

    return value
end

-- Internal helper: shallow-safe table ensure
local function EnsureTable(parent, key)
    if type(parent) ~= "table" then
        return {}
    end

    local value = parent[key]
    if type(value) ~= "table" then
        value = {}
        parent[key] = value
    end
    return value
end

local function ClampFontSize(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return nil
    end

    numeric = math.floor(numeric + 0.5)
    if numeric < 12 then
        numeric = 12
    elseif numeric > 36 then
        numeric = 36
    end

    return numeric
end

local function isDebugEnabled(addonTable)
    local utils = (addonTable and addonTable.Utils) or (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = (addonTable and addonTable.Diagnostics) or (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local root = addonTable or Nvk3UT
    if type(root) == "table" and type(root.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return root:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local sv = root and (root.sv or root.SV)
    if type(sv) == "table" and sv.debug ~= nil then
        return sv.debug == true
    end

    return false
end

-- SavedVariables defaults mirrored from the legacy core file.
-- TODO Model: split tracker/font defaults into dedicated settings modules.
local DEFAULT_FONT_FACE_BOLD = "$(BOLD_FONT)"
local DEFAULT_FONT_OUTLINE = "soft-shadow-thick"

local DEFAULT_QUEST_FONTS = {
    category = { face = DEFAULT_FONT_FACE_BOLD, size = 20, outline = DEFAULT_FONT_OUTLINE },
    title = { face = DEFAULT_FONT_FACE_BOLD, size = 16, outline = DEFAULT_FONT_OUTLINE },
    line = { face = DEFAULT_FONT_FACE_BOLD, size = 14, outline = DEFAULT_FONT_OUTLINE },
}

local DEFAULT_ACHIEVEMENT_FONTS = {
    category = { face = DEFAULT_FONT_FACE_BOLD, size = 20, outline = DEFAULT_FONT_OUTLINE },
    title = { face = DEFAULT_FONT_FACE_BOLD, size = 16, outline = DEFAULT_FONT_OUTLINE },
    line = { face = DEFAULT_FONT_FACE_BOLD, size = 14, outline = DEFAULT_FONT_OUTLINE },
}

local DEFAULT_ENDEAVOR_TRACKER_FONTS_TEMPLATE = {
    Category = { Face = DEFAULT_FONT_FACE_BOLD, Size = 20, Outline = DEFAULT_FONT_OUTLINE },
    Title = { Face = DEFAULT_FONT_FACE_BOLD, Size = 16, Outline = DEFAULT_FONT_OUTLINE },
    Objective = { Face = DEFAULT_FONT_FACE_BOLD, Size = 14, Outline = DEFAULT_FONT_OUTLINE },
}

local function CopyEndeavorFontDefaults()
    local template = DEFAULT_ENDEAVOR_TRACKER_FONTS_TEMPLATE
    return {
        Category = {
            Face = template.Category.Face,
            Size = template.Category.Size,
            Outline = template.Category.Outline,
        },
        Title = {
            Face = template.Title.Face,
            Size = template.Title.Size,
            Outline = template.Title.Outline,
        },
        Objective = {
            Face = template.Objective.Face,
            Size = template.Objective.Size,
            Outline = template.Objective.Outline,
        },
    }
end

local function CopyColor(color)
    if type(color) ~= "table" then
        return { r = 1, g = 1, b = 1, a = 1 }
    end

    return {
        r = color.r or 1,
        g = color.g or 1,
        b = color.b or 1,
        a = color.a or 1,
    }
end

local COLOR_CATEGORY = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 }
local COLOR_ENTRY = { r = 1, g = 1, b = 0, a = 1 }
local COLOR_ACTIVE = { r = 1, g = 1, b = 1, a = 1 }
local COLOR_COMPLETED = { r = 0.6, g = 0.6, b = 0.6, a = 1 }
local COLOR_MOUSEOVER_HIGHLIGHT = { r = 1, g = 1, b = 0.6, a = 1 }

local DEFAULT_TRACKER_APPEARANCE = {
    questTracker = {
        mouseoverHighlightColor = CopyColor(COLOR_MOUSEOVER_HIGHLIGHT),
        colors = {
            categoryTitle = CopyColor(COLOR_CATEGORY),
            objectiveText = CopyColor(COLOR_CATEGORY),
            entryTitle = CopyColor(COLOR_ENTRY),
            activeTitle = CopyColor(COLOR_ACTIVE),
        },
    },
    achievementTracker = {
        mouseoverHighlightColor = CopyColor(COLOR_MOUSEOVER_HIGHLIGHT),
        colors = {
            categoryTitle = CopyColor(COLOR_CATEGORY),
            objectiveText = CopyColor(COLOR_CATEGORY),
            entryTitle = CopyColor(COLOR_ENTRY),
            activeTitle = CopyColor(COLOR_ACTIVE),
        },
    },
    endeavorTracker = {
        mouseoverHighlightColor = CopyColor(COLOR_MOUSEOVER_HIGHLIGHT),
        colors = {
            categoryTitle = CopyColor(COLOR_CATEGORY),
            objectiveText = CopyColor(COLOR_CATEGORY),
            entryTitle = CopyColor(COLOR_ENTRY),
            activeTitle = CopyColor(COLOR_ACTIVE),
            completed = CopyColor(COLOR_COMPLETED),
        },
    },
    goldenTracker = {
        mouseoverHighlightColor = CopyColor(COLOR_MOUSEOVER_HIGHLIGHT),
        colors = {
            categoryTitleClosed = CopyColor(COLOR_CATEGORY),
            categoryTitleOpen = CopyColor(COLOR_ENTRY),
            entryTitle = CopyColor(COLOR_ENTRY),
            objectiveText = CopyColor(COLOR_CATEGORY),
            activeTitle = CopyColor(COLOR_ACTIVE),
            completed = CopyColor(COLOR_COMPLETED),
        },
    },
}

local DEFAULT_ENDEAVOR_SETTINGS = {
    Enabled = true,
    ShowCountsInHeaders = true,
    CompletedHandling = "hide",
    Colors = {
        CategoryTitle = CopyColor(COLOR_CATEGORY),
        EntryName = CopyColor(COLOR_ENTRY),
        Objective = CopyColor(COLOR_CATEGORY),
        Active = CopyColor(COLOR_ACTIVE),
        Completed = CopyColor(COLOR_COMPLETED),
    },
    Font = {
        Family = DEFAULT_FONT_FACE_BOLD,
        Size = DEFAULT_ACHIEVEMENT_FONTS.title.size,
        Outline = DEFAULT_FONT_OUTLINE,
    },
    Tracker = {
        Fonts = CopyEndeavorFontDefaults(),
    },
}

local DEFAULT_ENDEAVOR_DATA = {
    expanded = true,
    position = { x = nil, y = nil },
    window = { locked = false },
    categories = {},
    lastRefresh = 0,
}

local DEFAULT_GOLDEN_TRACKER_FONTS_TEMPLATE = {
    Category = { Face = DEFAULT_FONT_FACE_BOLD, Size = 20, Outline = DEFAULT_FONT_OUTLINE },
    Title = { Face = DEFAULT_FONT_FACE_BOLD, Size = 16, Outline = DEFAULT_FONT_OUTLINE },
    Objective = { Face = DEFAULT_FONT_FACE_BOLD, Size = 14, Outline = DEFAULT_FONT_OUTLINE },
}

local function CopyGoldenFontDefaults()
    local template = DEFAULT_GOLDEN_TRACKER_FONTS_TEMPLATE
    return {
        Category = {
            Face = template.Category.Face,
            Size = template.Category.Size,
            Outline = template.Category.Outline,
        },
        Title = {
            Face = template.Title.Face,
            Size = template.Title.Size,
            Outline = template.Title.Outline,
        },
        Objective = {
            Face = template.Objective.Face,
            Size = template.Objective.Size,
            Outline = template.Objective.Outline,
        },
    }
end

local function CreateTrackerDefaults(fontDefaultsCopier)
    local copyFonts = fontDefaultsCopier or CopyEndeavorFontDefaults
    return {
        Enabled = true,
        ShowCountsInHeaders = true,
        CompletedHandling = "hide",
        CompletedHandlingObjectives = "hide",
        Colors = {
            CategoryTitle = CopyColor(COLOR_CATEGORY),
            EntryName = CopyColor(COLOR_ENTRY),
            Objective = CopyColor(COLOR_CATEGORY),
            Active = CopyColor(COLOR_ACTIVE),
            Completed = CopyColor(COLOR_COMPLETED),
        },
        Font = {
            Family = DEFAULT_FONT_FACE_BOLD,
            Size = DEFAULT_ACHIEVEMENT_FONTS.title.size,
            Outline = DEFAULT_FONT_OUTLINE,
        },
        Tracker = {
            Fonts = copyFonts(),
        },
    }
end

local function CopySpacingDefaults()
    return {
        category = {
            indent = 0,
            spacingAbove = 3,
            spacingBelow = 3,
        },
        entry = {
            indent = 20,
            spacingAbove = 0,
            spacingBelow = 0,
        },
        objective = {
            indent = 40,
            spacingAbove = 3,
            spacingBelow = 3,
            spacingBetween = 1,
        },
    }
end

local defaultSV = {
    TrackerDefaults = {
        EndeavorDefaults = CreateTrackerDefaults(CopyEndeavorFontDefaults), -- Endeavor tracker defaults
        GoldenDefaults = CreateTrackerDefaults(CopyGoldenFontDefaults), -- Golden tracker defaults
    },
    TrackerData = {
        Endeavor = {},
        Golden = {},
    },
}

defaultSV.TrackerDefaults.GoldenDefaults.hideBaseGameTracking = true

local DEFAULT_HOST_SETTINGS = {
    HideInCombat = false,
    CornerButtonEnabled = true,
    CornerPosition = "TOP_RIGHT",
    sectionOrder = {
        "questSectionContainer",
        "endeavorSectionContainer",
        "achievementSectionContainer",
        "goldenSectionContainer",
    },
}

local DEFAULT_ACHIEVEMENT_CACHE = {
    buildHash = "",
    lastBuildAt = 0,
    categories = {
        Favorites = {},
        Recent = {},
        Completed = {},
        ToDo = {},
    },
}

local defaults = {
    version = 4,
    debug = false,
    General = {
        showStatus = false,
        favScope = "account",
        recentWindow = 0,
        recentMax = 100,
        showCategoryCounts = true,
        showQuestCategoryCounts = true,
        showAchievementCategoryCounts = true,
        hideBaseQuestTracker = true,
        window = {
            left = 200,
            top = 200,
            width = 360,
            height = 640,
            locked = false,
        },
        features = {
            completed = true,
            favorites = true,
            recent = true,
            todo = true,
            tooltips = true,
        },
    },
    QuestTracker = {
        active = true,
        hideDefault = false,
        hideInCombat = false,
        lock = false,
        autoGrowV = false,
        autoGrowH = false,
        autoExpand = true,
        autoTrack = true,
        autoCollapsePreviousCategoryOnActiveQuestChange = false,
        background = {
            enabled = true,
            alpha = 0.35,
            edgeAlpha = 0.5,
            padding = 8,
        },
        fonts = DEFAULT_QUEST_FONTS,
    },
    questFilter = {
        mode = 1,
        autoTrackNewQuestsInSelectionMode = true,
        selection = {},
    },
    AchievementTracker = {
        active = true,
        lock = false,
        autoGrowV = false,
        autoGrowH = false,
        background = {
            enabled = true,
            alpha = 0.35,
            edgeAlpha = 0.5,
            padding = 8,
        },
        fonts = DEFAULT_ACHIEVEMENT_FONTS,
        tooltips = true,
        sections = {
            favorites = true,
            recent = true,
            completed = true,
            todo = true,
        },
    },
    appearance = DEFAULT_TRACKER_APPEARANCE,
    Settings = {
        Host = DEFAULT_HOST_SETTINGS,
    },
    AchievementCache = DEFAULT_ACHIEVEMENT_CACHE,
    EndeavorData = DEFAULT_ENDEAVOR_DATA,
    Endeavor = DEFAULT_ENDEAVOR_SETTINGS,
    spacing = {
        quest = CopySpacingDefaults(),
        endeavor = CopySpacingDefaults(),
        achievement = CopySpacingDefaults(),
        golden = CopySpacingDefaults(),
    },
}

local ENDEAVOR_COLOR_ROLE_MAPPING = {
    CategoryTitle = "categoryTitle",
    EntryName = "entryTitle",
    Objective = "objectiveText",
    Active = "activeTitle",
    Completed = "completed",
}

local function NormalizeColorComponent(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        numeric = fallback ~= nil and fallback or 1
    end
    if numeric < 0 then
        numeric = 0
    elseif numeric > 1 then
        numeric = 1
    end
    return numeric
end

local function EnsureEndeavorSettings(saved)
    if type(saved) ~= "table" then
        return nil
    end

    local achievementSettings = saved.Achievement or saved.AchievementTracker
    local generalSettings = type(saved.General) == "table" and saved.General or nil
    local achievementColors = achievementSettings and (achievementSettings.Colors or achievementSettings.colors)
    local achievementFont = achievementSettings and (achievementSettings.Font or achievementSettings.font)

    local endeavor = Ensure(saved, "Endeavor", {})

    local enabledDefault = true
    if type(achievementSettings) == "table" then
        if achievementSettings.Enabled ~= nil then
            enabledDefault = achievementSettings.Enabled ~= false
        elseif achievementSettings.active ~= nil then
            enabledDefault = achievementSettings.active ~= false
        end
    end
    local legacyTracker = saved.EndeavorTracker
    if enabledDefault and type(legacyTracker) == "table" and legacyTracker.active ~= nil then
        enabledDefault = legacyTracker.active ~= false
    end
    endeavor.Enabled = Ensure(endeavor, "Enabled", enabledDefault) ~= false

    local headerDefault = true
    if type(achievementSettings) == "table" then
        if achievementSettings.ShowCountsInHeaders ~= nil then
            headerDefault = achievementSettings.ShowCountsInHeaders ~= false
        elseif achievementSettings.showCountsInHeaders ~= nil then
            headerDefault = achievementSettings.showCountsInHeaders ~= false
        end
    end
    if generalSettings and generalSettings.showAchievementCategoryCounts ~= nil then
        headerDefault = generalSettings.showAchievementCategoryCounts ~= false
    end
    endeavor.ShowCountsInHeaders = Ensure(endeavor, "ShowCountsInHeaders", headerDefault) ~= false

    if type(endeavor.CompletedHandling) ~= "string" then
        endeavor.CompletedHandling = Ensure(endeavor, "CompletedHandling", "hide")
    end
    local normalizedHandling = string.lower(endeavor.CompletedHandling)
    if normalizedHandling ~= "recolor" then
        endeavor.CompletedHandling = "hide"
    else
        endeavor.CompletedHandling = "recolor"
    end

    Ensure(endeavor, "Colors", {})
    local colors = endeavor.Colors
    local appearance = EnsureTable(saved, "appearance")
    local trackerAppearance = EnsureTable(appearance, "endeavorTracker")
    trackerAppearance.colors = type(trackerAppearance.colors) == "table" and trackerAppearance.colors or {}

    local function resolveSeedColor(configKey, role)
        local color = colors[configKey]
        if type(color) == "table" then
            return color
        end

        if type(achievementColors) == "table" then
            local candidate = achievementColors[configKey]
            if type(candidate) == "table" then
                return candidate
            end
        end

        local appearanceColors = trackerAppearance.colors
        if type(appearanceColors) == "table" then
            local candidate = appearanceColors[role]
            if type(candidate) == "table" then
                return candidate
            end
        end

        return defaults.Endeavor.Colors[configKey]
    end

    for configKey, role in pairs(ENDEAVOR_COLOR_ROLE_MAPPING) do
        local defaultColor = defaults.Endeavor.Colors[configKey]
        local seed = resolveSeedColor(configKey, role) or defaultColor

        local color = colors[configKey]
        if type(color) ~= "table" then
            color = ShallowCopy({}, seed)
            colors[configKey] = color
        end

        local seedR = (type(seed) == "table" and (seed.r or seed[1])) or defaultColor.r
        local seedG = (type(seed) == "table" and (seed.g or seed[2])) or defaultColor.g
        local seedB = (type(seed) == "table" and (seed.b or seed[3])) or defaultColor.b
        local seedA = (type(seed) == "table" and (seed.a or seed[4])) or defaultColor.a

        color.r = NormalizeColorComponent(color.r or color[1], seedR)
        color.g = NormalizeColorComponent(color.g or color[2], seedG)
        color.b = NormalizeColorComponent(color.b or color[3], seedB)
        color.a = NormalizeColorComponent(color.a or color[4], seedA)

        trackerAppearance.colors[role] = {
            r = color.r,
            g = color.g,
            b = color.b,
            a = color.a,
        }
    end

    local fontFallback = defaults.Endeavor.Font
    if type(achievementFont) == "table" then
        fontFallback = achievementFont
    end

    local font = Ensure(endeavor, "Font", fontFallback)
    if type(font) ~= "table" then
        font = Ensure(endeavor, "Font", fontFallback)
    end

    if type(font.Family) ~= "string" or font.Family == "" then
        font.Family = fontFallback.Family or defaults.Endeavor.Font.Family
    end

    local size = tonumber(font.Size)
    if size == nil then
        size = fontFallback.Size or defaults.Endeavor.Font.Size
    end
    size = math.floor(size + 0.5)
    if size < 12 then
        size = 12
    elseif size > 36 then
        size = 36
    end
    font.Size = size

    if type(font.Outline) ~= "string" or font.Outline == "" then
        font.Outline = fontFallback.Outline or defaults.Endeavor.Font.Outline
    end

    local tracker = endeavor.Tracker
    if type(tracker) ~= "table" then
        tracker = {}
        endeavor.Tracker = tracker
    end

    local fontsConfig = tracker.Fonts
    if type(fontsConfig) ~= "table" then
        fontsConfig = CopyEndeavorFontDefaults()
        tracker.Fonts = fontsConfig
    end

    local defaultsFonts =
        (defaults.Endeavor.Tracker and defaults.Endeavor.Tracker.Fonts)
        or CopyEndeavorFontDefaults()

    local fallbackFace = font.Family or defaults.Endeavor.Font.Family or DEFAULT_FONT_FACE_BOLD
    local fallbackOutline = font.Outline or defaults.Endeavor.Font.Outline or DEFAULT_FONT_OUTLINE
    local baseSize = ClampFontSize(font.Size) or defaults.Endeavor.Font.Size or DEFAULT_ACHIEVEMENT_FONTS.title.size

    local function fallbackSize(delta, defaultValue)
        local size = ClampFontSize(baseSize and (baseSize + delta))
        if size == nil then
            size = ClampFontSize(defaultValue)
        end
        if size == nil then
            size = DEFAULT_ACHIEVEMENT_FONTS.title.size
        end
        return size
    end

    local fallbackSizes = {
        Category = fallbackSize(4, defaultsFonts.Category and defaultsFonts.Category.Size),
        Title = fallbackSize(0, defaultsFonts.Title and defaultsFonts.Title.Size),
        Objective = fallbackSize(-2, defaultsFonts.Objective and defaultsFonts.Objective.Size),
    }

    local function ensureFontGroup(key)
        local group = fontsConfig[key]
        if type(group) ~= "table" then
            local altKey = type(key) == "string" and string.lower(key) or nil
            if altKey and type(fontsConfig[altKey]) == "table" then
                group = fontsConfig[altKey]
            end
        end
        if type(group) ~= "table" then
            group = {}
            fontsConfig[key] = group
        else
            fontsConfig[key] = group
        end

        local defaultGroup = defaultsFonts[key]

        local face = group.Face or group.face
        if type(face) ~= "string" or face == "" then
            face = fallbackFace
            if defaultGroup and type(defaultGroup.Face) == "string" and defaultGroup.Face ~= "" then
                face = defaultGroup.Face
            end
        end

        local outline = group.Outline or group.outline
        if type(outline) ~= "string" or outline == "" then
            outline = fallbackOutline
            if defaultGroup and type(defaultGroup.Outline) == "string" and defaultGroup.Outline ~= "" then
                outline = defaultGroup.Outline
            end
        end

        local size = ClampFontSize(group.Size or group.size)
        if size == nil then
            size = fallbackSizes[key]
        end
        if size == nil and defaultGroup then
            size = ClampFontSize(defaultGroup.Size)
        end
        if size == nil then
            size = DEFAULT_ACHIEVEMENT_FONTS.title.size
        end

        group.Face = face
        group.Size = size
        group.Outline = outline

        return group
    end

    ensureFontGroup("Category")
    ensureFontGroup("Title")
    ensureFontGroup("Objective")

    return endeavor
end

local function EnsureAchievementCache(saved)
    local cache = EnsureTable(saved, "AchievementCache")
    if cache.buildHash == nil then
        cache.buildHash = ""
    end
    if cache.lastBuildAt == nil then
        cache.lastBuildAt = 0
    end

    local categories = EnsureTable(cache, "categories")
    local favorites = EnsureTable(categories, "Favorites")
    local recent = EnsureTable(categories, "Recent")
    local completed = EnsureTable(categories, "Completed")
    local todoPrimary = EnsureTable(categories, "Todo")
    local todoAlternate = EnsureTable(categories, "ToDo")

    -- Keep Favorites/Recent/Completed references alive even if unused to avoid
    -- accidental nil assignments by callers expecting tables.
    favorites = favorites
    recent = recent
    completed = completed

    if todoAlternate ~= todoPrimary then
        if next(todoAlternate) ~= nil and next(todoPrimary) == nil then
            todoPrimary = todoAlternate
        elseif next(todoAlternate) ~= nil and next(todoPrimary) ~= nil then
            for key, value in pairs(todoAlternate) do
                if todoPrimary[key] == nil then
                    todoPrimary[key] = value
                end
            end
        end
    end

    categories.Todo = todoPrimary
    categories.ToDo = todoPrimary

    return cache
end

local function MergeDefaults(target, source)
    if type(source) ~= "table" then
        return target
    end

    if type(target) ~= "table" then
        target = {}
    end

    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = MergeDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end

    return target
end

local function EnsureEndeavorData(saved, safeCall)
    if type(saved) ~= "table" then
        return false
    end

    local endeavor = saved.EndeavorData
    local needsMerge = type(endeavor) ~= "table"

    if not needsMerge then
        if endeavor.expanded == nil then
            needsMerge = true
        end
        if type(endeavor.position) ~= "table" then
            needsMerge = true
        end
        if type(endeavor.window) ~= "table" then
            needsMerge = true
        end
        if type(endeavor.categories) ~= "table" then
            needsMerge = true
        end
        if endeavor.lastRefresh == nil then
            needsMerge = true
        end
    end

    local function applyDefaults()
        local target = EnsureTable(saved, "EndeavorData")
        MergeDefaults(target, DEFAULT_ENDEAVOR_DATA)
        EnsureTable(target, "position")
        local window = EnsureTable(target, "window")
        EnsureTable(target, "categories")

        if target.expanded == nil then
            target.expanded = DEFAULT_ENDEAVOR_DATA.expanded
        end

        if window.locked == nil then
            window.locked = DEFAULT_ENDEAVOR_DATA.window.locked
        end

        if target.lastRefresh == nil then
            target.lastRefresh = DEFAULT_ENDEAVOR_DATA.lastRefresh
        end

        return true
    end

    local initialized = false
    if needsMerge then
        if type(safeCall) == "function" then
            initialized = safeCall(applyDefaults) and true or false
        else
            initialized = applyDefaults()
        end
    else
        applyDefaults()
    end

    return initialized
end

local function AdoptLegacySettings(saved)
    if type(saved) ~= "table" then
        return
    end

    saved.General = MergeDefaults(saved.General, defaults.General)

    if type(saved.ui) == "table" then
        saved.General.showStatus = (saved.ui.showStatus ~= false)
        saved.General.favScope = saved.ui.favScope or saved.General.favScope
        saved.General.recentWindow = saved.ui.recentWindow or saved.General.recentWindow
        saved.General.recentMax = saved.ui.recentMax or saved.General.recentMax
    end

    saved.General.features = MergeDefaults(saved.General.features, defaults.General.features)
    if type(saved.features) == "table" then
        for key, value in pairs(saved.features) do
            saved.General.features[key] = value
        end
    end

    saved.QuestTracker = MergeDefaults(saved.QuestTracker, defaults.QuestTracker)
    saved.questFilter = MergeDefaults(saved.questFilter, defaults.questFilter)
    saved.AchievementTracker = MergeDefaults(saved.AchievementTracker, defaults.AchievementTracker)
    saved.appearance = MergeDefaults(saved.appearance, defaults.appearance)

    EnsureEndeavorSettings(saved)

    saved.ui = saved.General
    saved.features = saved.General.features
end

local function EnsureFirstLoginStructures(saved)
    local general = EnsureTable(saved, "General")
    MergeDefaults(general, defaults.General)
    MergeDefaults(EnsureTable(general, "features"), defaults.General.features)
    MergeDefaults(EnsureTable(general, "window"), defaults.General.window)
    EnsureTable(general, "Appearance")
    EnsureTable(general, "layout")
    EnsureTable(general, "WindowBars")

    local questTracker = EnsureTable(saved, "QuestTracker")
    MergeDefaults(questTracker, defaults.QuestTracker)
    MergeDefaults(EnsureTable(questTracker, "background"), defaults.QuestTracker.background)
    MergeDefaults(EnsureTable(questTracker, "fonts"), defaults.QuestTracker.fonts)

    local questFilter = EnsureTable(saved, "questFilter")
    MergeDefaults(questFilter, defaults.questFilter)
    EnsureTable(questFilter, "selection")

    local achievementTracker = EnsureTable(saved, "AchievementTracker")
    MergeDefaults(achievementTracker, defaults.AchievementTracker)
    MergeDefaults(EnsureTable(achievementTracker, "background"), defaults.AchievementTracker.background)
    MergeDefaults(EnsureTable(achievementTracker, "fonts"), defaults.AchievementTracker.fonts)
    MergeDefaults(EnsureTable(achievementTracker, "sections"), defaults.AchievementTracker.sections)

    local appearance = EnsureTable(saved, "appearance")
    MergeDefaults(appearance, defaults.appearance)
    EnsureEndeavorSettings(saved)
    EnsureTable(appearance, "questTracker")
    EnsureTable(appearance, "achievementTracker")

    local spacing = EnsureTable(saved, "spacing")
    MergeDefaults(EnsureTable(spacing, "quest"), defaults.spacing.quest)
    MergeDefaults(EnsureTable(spacing, "endeavor"), defaults.spacing.endeavor)
    MergeDefaults(EnsureTable(spacing, "achievement"), defaults.spacing.achievement)
    MergeDefaults(EnsureTable(spacing, "golden"), defaults.spacing.golden)

    local settings = EnsureTable(saved, "Settings")
    local hostSettings = EnsureTable(settings, "Host")
    if hostSettings.HideInCombat == nil then
        if saved.QuestTracker and saved.QuestTracker.hideInCombat ~= nil then
            hostSettings.HideInCombat = saved.QuestTracker.hideInCombat == true
        else
            hostSettings.HideInCombat = DEFAULT_HOST_SETTINGS.HideInCombat
        end
    else
        hostSettings.HideInCombat = hostSettings.HideInCombat == true
    end
    MergeDefaults(settings, defaults.Settings)
    MergeDefaults(hostSettings, defaults.Settings.Host)

    if saved.debug == nil then
        saved.debug = defaults.debug
    end
    if saved.version == nil then
        saved.version = defaults.version
    end

    EnsureAchievementCache(saved)
end

function Nvk3UT_StateInit:InitDefaults()
    self.defaultSV = MergeDefaults(self.defaultSV, defaultSV)

    local trackerDefaults = EnsureTable(self.defaultSV, "TrackerDefaults")
    local questDefaults = trackerDefaults.QuestDefaults
    local achievementDefaults = trackerDefaults.AchievementDefaults

    if questDefaults ~= nil then
        trackerDefaults.QuestDefaults = questDefaults
    end

    trackerDefaults.EndeavorDefaults = MergeDefaults(trackerDefaults.EndeavorDefaults, defaultSV.TrackerDefaults.EndeavorDefaults)

    if achievementDefaults ~= nil then
        trackerDefaults.AchievementDefaults = achievementDefaults
    end

    trackerDefaults.GoldenDefaults = MergeDefaults(trackerDefaults.GoldenDefaults, defaultSV.TrackerDefaults.GoldenDefaults)

    local trackerData = EnsureTable(self.defaultSV, "TrackerData")
    if trackerData.Quest ~= nil then
        EnsureTable(trackerData, "Quest")
    end

    EnsureTable(trackerData, "Endeavor")

    if trackerData.Achievement ~= nil then
        EnsureTable(trackerData, "Achievement")
    end

    EnsureTable(trackerData, "Golden")

    if isDebugEnabled(Nvk3UT) then
        local orderParts = { "Quest", "Endeavor", "Achievement", "Golden" }
        local orderMessage = table.concat(orderParts, " → ")

        if Nvk3UT and type(Nvk3UT.Debug) == "function" then
            Nvk3UT.Debug("InitDefaults tracker order: %s", orderMessage)
        elseif d then
            d(string.format("[Nvk3UT DEBUG] InitDefaults tracker order: %s", orderMessage))
        end
    end

    return self.defaultSV
end

-- Create or load SavedVariables and ensure all required subtables/fields exist.
-- addonTable is expected to be the global addon table Nvk3UT.
-- Returns the SavedVariables table.
function Nvk3UT_StateInit.BootstrapSavedVariables(addonTable)
    if type(addonTable) ~= "table" then
        return nil
    end

    local sv = addonTable.SV
    if type(sv) ~= "table" then
        sv = ZO_SavedVars:NewAccountWide("Nvk3UT_SV", 2, nil, defaults)
        addonTable.SV = sv
    end

    AdoptLegacySettings(sv)
    EnsureFirstLoginStructures(sv)

    local safeCall = addonTable and addonTable.SafeCall
    if not safeCall and Nvk3UT and type(Nvk3UT.SafeCall) == "function" then
        safeCall = Nvk3UT.SafeCall
    end

    local endeavorInitialized = EnsureEndeavorData(sv, safeCall)

    addonTable.SV = sv
    addonTable.sv = sv

    if type(addonTable.SetDebugEnabled) == "function" then
        addonTable:SetDebugEnabled(sv.debug)
    end

    local debugActive = isDebugEnabled(addonTable)

    if endeavorInitialized and debugActive and type(addonTable.Debug) == "function" then
        addonTable.Debug("Initialized EndeavorData defaults")
    elseif endeavorInitialized and debugActive and d then
        d("[Nvk3UT DEBUG] Initialized EndeavorData defaults")
    end

    if Nvk3UT_Diagnostics and Nvk3UT_Diagnostics.SyncFromSavedVariables then
        Nvk3UT_Diagnostics.SyncFromSavedVariables(sv)
    end

    return sv
end

Nvk3UT_StateInit.defaultSV = defaultSV

return Nvk3UT_StateInit
