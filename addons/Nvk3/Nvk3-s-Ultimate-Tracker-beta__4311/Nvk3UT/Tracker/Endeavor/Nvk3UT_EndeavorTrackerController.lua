-- Tracker/Endeavor/Nvk3UT_EndeavorTrackerController.lua
-- Builds Endeavor tracker view models from the Endeavor model snapshot.

local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Controller = Nvk3UT.EndeavorTrackerController or {}
Nvk3UT.EndeavorTrackerController = Controller

local function getRoot()
    local root = rawget(_G, addonName)
    if type(root) == "table" then
        return root
    end

    return Nvk3UT
end

local function getSavedVars()
    local root = getRoot()
    if type(root) ~= "table" then
        return nil
    end

    return rawget(root, "sv")
end

local function getConfig()
    local saved = getSavedVars()
    if type(saved) ~= "table" then
        return {}
    end

    local config = saved.Endeavor
    if type(config) ~= "table" then
        return {}
    end

    return config
end

local function resolveEnabled(config)
    if type(config) == "table" and config.Enabled ~= nil then
        return config.Enabled ~= false
    end

    local saved = getSavedVars()
    local achievement = saved and saved.AchievementTracker
    if type(achievement) == "table" and achievement.active ~= nil then
        return achievement.active ~= false
    end

    return true
end

local function resolveShowCounts(config)
    if type(config) == "table" and config.ShowCountsInHeaders ~= nil then
        return config.ShowCountsInHeaders ~= false
    end

    local saved = getSavedVars()
    local general = saved and saved.General
    if type(general) == "table" and general.showAchievementCategoryCounts ~= nil then
        return general.showAchievementCategoryCounts ~= false
    end

    return true
end

local function resolveCompletedHandling(config)
    if type(config) == "table" and config.CompletedHandling == "recolor" then
        return "recolor"
    end
    return "hide"
end

local DEFAULT_COLOR_CATEGORY = { r = 0.7725, g = 0.7608, b = 0.6196, a = 1 }
local DEFAULT_COLOR_ENTRY = { r = 1, g = 1, b = 0, a = 1 }
local DEFAULT_COLOR_ACTIVE = { r = 1, g = 1, b = 1, a = 1 }
local DEFAULT_COLOR_COMPLETED = { r = 0.6, g = 0.6, b = 0.6, a = 1 }
local DEFAULT_COLOR_OBJECTIVE = DEFAULT_COLOR_CATEGORY

local DEFAULT_FONT_FACE = "$(BOLD_FONT)"
local DEFAULT_FONT_OUTLINE = "soft-shadow-thick"
local DEFAULT_FONT_SIZE = 16
local DEFAULT_CATEGORY_FONT_SIZE = 20
local DEFAULT_TITLE_FONT_SIZE = 16
local DEFAULT_OBJECTIVE_FONT_SIZE = 14

local function buildFontString(face, size, outline)
    return string.format("%s|%d|%s", face, size, outline)
end

local function normalizeColorComponent(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        numeric = fallback or 1
    end

    if numeric ~= numeric then
        numeric = fallback or 1
    end

    if numeric < 0 then
        numeric = 0
    elseif numeric > 1 then
        numeric = 1
    end

    return numeric
end

local function copyColor(source, fallback)
    local default = fallback or DEFAULT_COLOR_ACTIVE
    local r = normalizeColorComponent(source and (source.r or source[1]), default.r or default[1] or 1)
    local g = normalizeColorComponent(source and (source.g or source[2]), default.g or default[2] or 1)
    local b = normalizeColorComponent(source and (source.b or source[3]), default.b or default[3] or 1)
    local a = normalizeColorComponent(source and (source.a or source[4]), default.a or default[4] or 1)

    return { r = r, g = g, b = b, a = a }
end

local function buildColors(config)
    local colorsConfig = type(config) == "table" and config.Colors or nil
    return {
        categoryTitle = copyColor(colorsConfig and colorsConfig.CategoryTitle, DEFAULT_COLOR_CATEGORY),
        entryTitle = copyColor(colorsConfig and colorsConfig.EntryName, DEFAULT_COLOR_ENTRY),
        objectiveText = copyColor(colorsConfig and colorsConfig.Objective, DEFAULT_COLOR_OBJECTIVE),
        activeTitle = copyColor(colorsConfig and colorsConfig.Active, DEFAULT_COLOR_ACTIVE),
        completed = copyColor(colorsConfig and colorsConfig.Completed, DEFAULT_COLOR_COMPLETED),
    }
end

local function clampFontSize(value)
    local numeric = tonumber(value)
    if numeric == nil then
        numeric = DEFAULT_FONT_SIZE
    end
    numeric = math.floor(numeric + 0.5)
    if numeric < 12 then
        numeric = 12
    elseif numeric > 36 then
        numeric = 36
    end
    return numeric
end

local function buildFontStrings(config)
    local rootConfig = type(config) == "table" and config or {}
    local tracker = type(rootConfig.Tracker) == "table" and rootConfig.Tracker or nil
    local fontsConfig = tracker and tracker.Fonts
    local legacyFont = type(rootConfig.Font) == "table" and rootConfig.Font or nil

    local fallbackFace = DEFAULT_FONT_FACE
    if legacyFont and type(legacyFont.Family) == "string" and legacyFont.Family ~= "" then
        fallbackFace = legacyFont.Family
    end

    local fallbackOutline = DEFAULT_FONT_OUTLINE
    if legacyFont and type(legacyFont.Outline) == "string" and legacyFont.Outline ~= "" then
        fallbackOutline = legacyFont.Outline
    end

    local baseSize = DEFAULT_FONT_SIZE
    if legacyFont and legacyFont.Size ~= nil then
        baseSize = clampFontSize(legacyFont.Size)
    end

    local fallbackCategorySize = clampFontSize(baseSize + 4)
    local fallbackTitleSize = clampFontSize(baseSize)
    local fallbackObjectiveSize = clampFontSize(baseSize - 2)

    local function selectGroup(key)
        if type(fontsConfig) ~= "table" then
            return nil
        end
        local group = fontsConfig[key]
        if type(group) ~= "table" then
            local altKey = type(key) == "string" and string.lower(key) or nil
            if altKey and type(fontsConfig[altKey]) == "table" then
                group = fontsConfig[altKey]
            end
        end
        return group
    end

    local function resolveGroup(groupConfig, defaultSize, fallbackSize)
        local face = fallbackFace
        local outline = fallbackOutline
        local size = fallbackSize or defaultSize

        if type(groupConfig) == "table" then
            local faceCandidate = groupConfig.Face or groupConfig.face
            if type(faceCandidate) == "string" and faceCandidate ~= "" then
                face = faceCandidate
            end

            local outlineCandidate = groupConfig.Outline or groupConfig.outline
            if type(outlineCandidate) == "string" and outlineCandidate ~= "" then
                outline = outlineCandidate
            end

            local sizeCandidate = groupConfig.Size or groupConfig.size
            if sizeCandidate ~= nil then
                size = clampFontSize(sizeCandidate)
            end
        end

        if size == nil then
            size = defaultSize
        end
        if size == nil then
            size = DEFAULT_TITLE_FONT_SIZE
        end
        size = clampFontSize(size)

        return buildFontString(face, size, outline), face, size, outline
    end

    local categoryFont, categoryFace, categorySize, categoryOutline =
        resolveGroup(selectGroup("Category"), DEFAULT_CATEGORY_FONT_SIZE, fallbackCategorySize)
    local titleFont, titleFace, titleSize, titleOutline =
        resolveGroup(selectGroup("Title"), DEFAULT_TITLE_FONT_SIZE, fallbackTitleSize)
    local objectiveFont, objectiveFace, objectiveSize, objectiveOutline =
        resolveGroup(selectGroup("Objective"), DEFAULT_OBJECTIVE_FONT_SIZE, fallbackObjectiveSize)

    local fonts = {
        category = categoryFont,
        section = titleFont,
        objective = objectiveFont,
        family = titleFace or fallbackFace,
        outline = titleOutline or fallbackOutline,
        baseSize = titleSize,
        categorySize = categorySize,
        objectiveSize = objectiveSize,
        categoryOutline = categoryOutline,
        objectiveOutline = objectiveOutline,
    }

    fonts.rowHeight = math.max((objectiveSize or DEFAULT_OBJECTIVE_FONT_SIZE) + 6, 20)

    return fonts
end

local function buildRowsOptions(colors, fonts, completedHandling, fontConfig)
    return {
        font = fonts.objective,
        rowHeight = fonts.rowHeight,
        colors = colors,
        colorKind = "endeavorTracker",
        defaultRole = "objectiveText",
        completedRole = "completed",
        entryRole = "entryTitle",
        completedHandling = completedHandling,
        fontConfig = fontConfig,
    }
end

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local root = getRoot()
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

-- local debug logger
local function DBG(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local ok, message = pcall(string.format, fmt or "", ...)
    if not ok then
        message = tostring(fmt)
    end

    if type(d) == "function" then
        d("[EndeavorController] " .. message)
    elseif type(print) == "function" then
        print("[EndeavorController] " .. message)
    end
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local root = getRoot()
    if type(root) == "table" then
        local safe = rawget(root, "SafeCall")
        if type(safe) == "function" then
            return safe(fn, ...)
        end
    end

    local results = { pcall(fn, ...) }
    if results[1] then
        table.remove(results, 1)
        if #results == 0 then
            return nil
        end
        return unpack(results)
    end

    return nil
end

local function callWithOptionalSelf(target, method, ...)
    if type(method) ~= "function" then
        return nil
    end

    local args = { ... }

    local results = { safeCall(function()
        if target ~= nil then
            return method(target, unpack(args))
        end

        return method(unpack(args))
    end) }

    if #results == 0 then
        return nil
    end

    return unpack(results)
end


local function coerceNumber(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        numeric = fallback or 0
    end

    if numeric ~= numeric then
        numeric = fallback or 0
    end

    return numeric
end

local function clampNonNegative(value, fallback)
    local numeric = coerceNumber(value, fallback or 0)
    if numeric < 0 then
        numeric = 0
    end

    return numeric
end

local function clampProgress(value, maxValue)
    local numeric = clampNonNegative(value, 0)
    if type(maxValue) == "number" and maxValue >= 0 and numeric > maxValue then
        numeric = maxValue
    end

    return numeric
end

local function clampMax(value)
    local numeric = coerceNumber(value, 1)
    if numeric < 1 then
        numeric = 1
    end

    return numeric
end

local function coerceBoolean(value)
    return value == true
end

local function getStateModule()
    local root = getRoot()
    if type(root) ~= "table" then
        return nil
    end

    local stateModule = rawget(root, "EndeavorState")
    if type(stateModule) ~= "table" then
        return nil
    end

    return stateModule
end

local function isStateExpanded(stateModule)
    if type(stateModule) ~= "table" then
        return false
    end

    local method = stateModule.IsExpanded
    if type(method) ~= "function" then
        return false
    end

    local ok, expanded = pcall(method, stateModule)
    return ok and expanded == true
end

local function isCategoryExpanded(stateModule, key)
    if type(stateModule) ~= "table" then
        return false
    end

    local method = stateModule.IsCategoryExpanded
    if type(method) ~= "function" then
        return false
    end

    local ok, expanded = pcall(method, stateModule, key)
    return ok and expanded == true
end

function Controller:BuildViewModel()
    local aggregatedItems = {}
    local dailyObjectives = {}
    local weeklyObjectives = {}
    local dailyCompleted = 0
    local dailyTotal = 0
    local weeklyCompleted = 0
    local weeklyTotal = 0
    local dailyDisplayCompleted = 0
    local dailyDisplayLimit = 0
    local weeklyDisplayCompleted = 0
    local weeklyDisplayLimit = 0

    local root = getRoot()
    local model = root and rawget(root, "EndeavorModel")

    local viewData
    if type(model) == "table" then
        local getViewData = model.GetViewData or model.GetViewModel
        if type(getViewData) == "function" then
            viewData = callWithOptionalSelf(model, getViewData)
        end
    end

    if type(viewData) ~= "table" then
        viewData = {}
    end

    local summary
    if type(model) == "table" then
        local getSummary = model.GetSummary
        if type(getSummary) == "function" then
            local ok, result = pcall(getSummary, model)
            if ok and type(result) == "table" then
                summary = result
            end
        end
    end

    local dailyBucket = type(viewData.daily) == "table" and viewData.daily or {}
    local weeklyBucket = type(viewData.weekly) == "table" and viewData.weekly or {}

    dailyCompleted = clampNonNegative(summary and summary.dailyCompleted or dailyBucket.completed, 0)
    dailyTotal = clampNonNegative(summary and summary.dailyTotal or dailyBucket.total, 0)
    weeklyCompleted = clampNonNegative(summary and summary.weeklyCompleted or weeklyBucket.completed, 0)
    weeklyTotal = clampNonNegative(summary and summary.weeklyTotal or weeklyBucket.total, 0)

    local config = getConfig()
    local enabled = resolveEnabled(config)
    local showCounts = resolveShowCounts(config)
    local completedHandling = resolveCompletedHandling(config)
    local DAILY_LIMIT = 3
    local WEEKLY_LIMIT = 1

    local dailyLimitValue = clampNonNegative(summary and summary.dailyLimit or dailyBucket.limit, DAILY_LIMIT)
    local weeklyLimitValue = clampNonNegative(summary and summary.weeklyLimit or weeklyBucket.limit, WEEKLY_LIMIT)

    local isDailyCapped = false
    local isWeeklyCapped = false

    if type(model) == "table" then
        local getDailyCap = model.IsDailyCapped
        if type(getDailyCap) == "function" then
            local ok, capped = pcall(getDailyCap, model)
            if ok and capped ~= nil then
                isDailyCapped = capped == true
            end
        end

        local getWeeklyCap = model.IsWeeklyCapped
        if type(getWeeklyCap) == "function" then
            local ok, capped = pcall(getWeeklyCap, model)
            if ok and capped ~= nil then
                isWeeklyCapped = capped == true
            end
        end
    end

    if not isDailyCapped then
        isDailyCapped = dailyLimitValue > 0 and dailyCompleted >= dailyLimitValue
    end

    if not isWeeklyCapped then
        isWeeklyCapped = weeklyLimitValue > 0 and weeklyCompleted >= weeklyLimitValue
    end

    local colors = buildColors(config)
    local fonts = buildFontStrings(config)
    local trackerConfig = type(config) == "table" and config.Tracker or nil
    local fontConfig = trackerConfig and trackerConfig.Fonts or nil
    local rowsOptions = buildRowsOptions(colors, fonts, completedHandling, fontConfig)

    if not enabled then
        local stateModule = getStateModule()
        return {
            category = {
                title = GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_ROOT),
                expanded = isStateExpanded(stateModule),
                remaining = 0,
            },
            daily = {
                title = GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_DAILY),
                completed = 0,
                total = 0,
                displayCompleted = 0,
                displayLimit = DAILY_LIMIT,
                expanded = isCategoryExpanded(stateModule, "daily"),
                objectives = {},
            },
            weekly = {
                title = GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_WEEKLY),
                completed = 0,
                total = 0,
                displayCompleted = 0,
                displayLimit = WEEKLY_LIMIT,
                expanded = isCategoryExpanded(stateModule, "weekly"),
                objectives = {},
            },
            items = {},
            count = 0,
            settings = {
                enabled = false,
                showCounts = showCounts,
                completedHandling = completedHandling,
                colors = colors,
                fonts = fonts,
                rowsOptions = rowsOptions,
            },
        }
    end

    dailyDisplayLimit = dailyLimitValue > 0 and dailyLimitValue or DAILY_LIMIT
    weeklyDisplayLimit = weeklyLimitValue > 0 and weeklyLimitValue or WEEKLY_LIMIT

    local dailyCompletedValue = clampNonNegative(dailyCompleted, 0)
    local weeklyCompletedValue = clampNonNegative(weeklyCompleted, 0)

    local dailyDoneCapped = math.min(dailyCompletedValue, dailyDisplayLimit)
    local weeklyDoneCapped = math.min(weeklyCompletedValue, weeklyDisplayLimit)

    dailyDisplayCompleted = dailyDoneCapped
    weeklyDisplayCompleted = weeklyDoneCapped

    local function mapObjective(item, kind)
        if type(item) ~= "table" then
            return nil, nil
        end

        local maxValue = clampMax(item.maxProgress)
        local progressValue = clampProgress(item.progress, maxValue)
        local completed = item.completed == true or progressValue >= maxValue

        local objective = {
            text = tostring(item.name or ""),
            progress = progressValue,
            max = maxValue,
            completed = completed,
            remainingSeconds = clampNonNegative(item.remainingSeconds, 0),
            id = item.id,
            kind = kind,
        }

        local aggregated = {
            name = tostring(item.name or ""),
            description = tostring(item.description or ""),
            progress = progressValue,
            maxProgress = maxValue,
            type = nil,
            remainingSeconds = objective.remainingSeconds,
            completed = completed,
            id = item.id,
            kind = kind,
        }

        return objective, aggregated
    end

    local includeCompleted = completedHandling == "recolor"

    local function buildObjectives(bucket, target, kind)
        if type(bucket) ~= "table" or type(target) ~= "table" then
            return
        end

        local list = bucket.items
        if type(list) ~= "table" then
            return
        end

        for _, item in ipairs(list) do
            local objective, aggregated = mapObjective(item, kind)
            if objective then
                if aggregated then
                    aggregated.type = kind
                    aggregatedItems[#aggregatedItems + 1] = aggregated
                end

                if includeCompleted or objective.completed ~= true then
                    target[#target + 1] = objective
                end
            end
        end
    end

    buildObjectives(dailyBucket, dailyObjectives, "daily")
    buildObjectives(weeklyBucket, weeklyObjectives, "weekly")

    local remainingDaily = math.max(0, dailyDisplayLimit - dailyDoneCapped)
    local remainingWeekly = math.max(0, weeklyDisplayLimit - weeklyDoneCapped)
    local remainingTotal = remainingDaily + remainingWeekly

    local stateModule = getStateModule()
    local dailyHideRow = completedHandling == "hide" and isDailyCapped
    local weeklyHideRow = completedHandling == "hide" and isWeeklyCapped
    local dailyHideObjectives = isDailyCapped
    local weeklyHideObjectives = isWeeklyCapped
    local dailyUseCompletedStyle = completedHandling == "recolor" and isDailyCapped
    local weeklyUseCompletedStyle = completedHandling == "recolor" and isWeeklyCapped
    local hideEntireSection = completedHandling == "hide" and dailyHideRow and weeklyHideRow

    local vm = {
        category = {
            kind = "endeavorCategoryHeader",
            title = GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_ROOT),
            expanded = isStateExpanded(stateModule),
            remaining = remainingTotal,
        },
        daily = {
            kind = "dailyHeader",
            title = GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_DAILY),
            completed = dailyCompleted,
            total = dailyTotal,
            displayCompleted = dailyDisplayCompleted,
            displayLimit = dailyDisplayLimit,
            expanded = isCategoryExpanded(stateModule, "daily"),
            objectives = dailyObjectives,
            isCapped = isDailyCapped,
            hideRow = dailyHideRow,
            hideObjectives = dailyHideObjectives,
            useCompletedStyle = dailyUseCompletedStyle,
        },
        weekly = {
            kind = "weeklyHeader",
            title = GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_WEEKLY),
            completed = weeklyCompleted,
            total = weeklyTotal,
            displayCompleted = weeklyDisplayCompleted,
            displayLimit = weeklyDisplayLimit,
            expanded = isCategoryExpanded(stateModule, "weekly"),
            objectives = weeklyObjectives,
            isCapped = isWeeklyCapped,
            hideRow = weeklyHideRow,
            hideObjectives = weeklyHideObjectives,
            useCompletedStyle = weeklyUseCompletedStyle,
        },
        items = aggregatedItems,
        count = #aggregatedItems,
        section = {
            hideEntireSection = hideEntireSection,
        },
    }

    DBG(
        "[EndeavorVM] remaining=%d daily=%d/%d weekly=%d/%d objsD=%d objsW=%d",
        remainingTotal,
        dailyDisplayCompleted,
        dailyDisplayLimit,
        weeklyDisplayCompleted,
        weeklyDisplayLimit,
        #dailyObjectives,
        #weeklyObjectives
    )

    vm.settings = {
        enabled = true,
        showCounts = showCounts,
        completedHandling = completedHandling,
        colors = colors,
        fonts = fonts,
        rowsOptions = rowsOptions,
    }

    DBG(
        "caps: daily capped=%s hideRow=%s hideObjectives=%s completedStyle=%s | weekly capped=%s hideRow=%s hideObjectives=%s completedStyle=%s | section.hideEntire=%s",
        tostring(isDailyCapped),
        tostring(dailyHideRow),
        tostring(dailyHideObjectives),
        tostring(dailyUseCompletedStyle),
        tostring(isWeeklyCapped),
        tostring(weeklyHideRow),
        tostring(weeklyHideObjectives),
        tostring(weeklyUseCompletedStyle),
        tostring(hideEntireSection)
    )

    return vm
end

return Controller
